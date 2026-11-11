import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/home/data/local_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('secure session store restores, replaces, and clears a user', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final sessions = SecureAuthSessionStore();
    final user = AuthUser(
      phone: '959254135592',
      firstName: 'မေ သက်',
      lastName: 'Aung',
      birthDate: DateTime(2000, 2, 29),
    );

    await sessions.write(user);
    final restored = await sessions.read();
    expect(restored?.phone, user.phone);
    expect(restored?.firstName, user.firstName);
    expect(restored?.lastName, user.lastName);
    expect(restored?.birthDate, user.birthDate);

    await sessions.clear();
    expect(await sessions.read(), isNull);
  });

  test(
    'a malformed stored session is cleared and returns a typed failure',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'jdonuts.auth.session.v1': 'not-valid-json',
      });
      final sessions = SecureAuthSessionStore();
      final repository = LocalAuthRepository(
        sessionStore: sessions,
        accountStore: MemoryAuthAccountStore(),
        delay: (_) async {},
      );

      final result = await repository.currentSession();

      expect(result, isA<Error<AuthUser?>>());
      expect((result as Error<AuthUser?>).failure, isA<StorageFailure>());
      expect(await sessions.read(), isNull);
    },
  );

  test(
    'SQLite account and persisted session survive repository recreation',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final accounts = DriftAuthAccountStore(database);
      final sessions = SecureAuthSessionStore();
      final firstRepository = LocalAuthRepository(
        accountStore: accounts,
        sessionStore: sessions,
        delay: (_) async {},
      );
      final user = AuthUser(
        phone: '959254135592',
        firstName: 'မေ သက်',
        lastName: 'Aung',
        birthDate: DateTime(2000, 2, 29),
      );

      await firstRepository.verifyOtp(user.phone, fakeOtpCode);
      await firstRepository.saveRegistrationProfile(user);
      expect(await firstRepository.register(user), isA<Success<AuthUser>>());

      final stored = await DriftAuthAccountStore(database).find(user.phone);
      expect(stored?.firstName, user.firstName);
      expect(stored?.lastName, user.lastName);
      expect(stored?.birthDate, user.birthDate);

      final relaunchedRepository = LocalAuthRepository(
        accountStore: accounts,
        sessionStore: SecureAuthSessionStore(),
        delay: (_) async {},
      );
      expect(await _value(relaunchedRepository.hasSession()), isTrue);
      expect(
        await relaunchedRepository.login(user.phone, fakeOtpCode),
        isA<Success<AuthUser>>(),
      );
      expect(await _value(relaunchedRepository.logout()), isTrue);
      expect(await _value(relaunchedRepository.hasSession()), isFalse);
      expect(await accounts.find(user.phone), isNotNull);
      final membership =
          await (database.select(database.memberRows)
                ..where((member) => member.accountPhone.equals(user.phone)))
              .getSingleOrNull();
      expect(membership, isNotNull);
      expect(membership?.points, 680000);
    },
  );

  test(
    'account creation is unique and creates one membership profile',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final accounts = DriftAuthAccountStore(database);
      const user = AuthUser(
        phone: '95922222222',
        firstName: 'May',
        lastName: 'Aung',
        birthDate: null,
      );

      await accounts.create(user);
      await expectLater(
        accounts.create(user),
        throwsA(isA<DuplicateAuthAccount>()),
      );

      expect(
        await database.select(database.authAccountRows).get(),
        hasLength(1),
      );
      final profile = await database.select(database.memberRows).getSingle();
      expect(profile.accountPhone, user.phone);
      expect(profile.name, 'May Aung');
      expect(profile.points, 680000);
      expect(profile.pointsToGold, 500);
    },
  );

  test('failed profile insert rolls back the new account row', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    const user = AuthUser(
      phone: '95933333333',
      firstName: 'May',
      lastName: 'Aung',
      birthDate: null,
    );
    await database
        .into(database.memberRows)
        .insert(
          MemberRowsCompanion.insert(
            id: 'member-${user.phone}',
            name: 'Conflicting row',
            tier: 'Silver',
            points: 680000,
            pointsToGold: 500,
            notifications: 0,
          ),
        );
    final accounts = DriftAuthAccountStore(database);

    await expectLater(accounts.create(user), throwsA(isA<Exception>()));

    expect(await database.select(database.authAccountRows).get(), isEmpty);
  });

  test(
    'failed secure session write removes profile and member challenges',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database
          .into(database.challengeRows)
          .insert(
            ChallengeRowsCompanion.insert(
              id: 'donut-4',
              title: 'Eat 4 donuts',
              progress: 1,
              target: 4,
              points: 100,
              kind: 'donut',
            ),
          );
      const user = AuthUser(
        phone: '95944444444',
        firstName: 'May',
        lastName: 'Aung',
        birthDate: null,
      );
      final repository = LocalAuthRepository(
        delay: (_) async {},
        accountStore: DriftAuthAccountStore(database),
        sessionStore: _FailingSessionStore(),
      );
      await repository.verifyOtp(user.phone, fakeOtpCode);
      await repository.saveRegistrationProfile(user);

      final result = await repository.register(
        AuthUser(
          phone: user.phone,
          firstName: user.firstName,
          lastName: user.lastName,
          birthDate: DateTime(2000, 1, 1),
        ),
      );

      expect(result, isA<Error<AuthUser>>());
      expect(await database.select(database.authAccountRows).get(), isEmpty);
      expect(await database.select(database.memberRows).get(), isEmpty);
      expect(
        await database.select(database.memberChallengeRows).get(),
        isEmpty,
      );
    },
  );

  test('logout and login switch to the matching member profile', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final accounts = DriftAuthAccountStore(database);
    const first = AuthUser(
      phone: '95955555555',
      firstName: 'May',
      lastName: 'Aung',
      birthDate: null,
    );
    const second = AuthUser(
      phone: '95966666666',
      firstName: 'May',
      lastName: 'Aung',
      birthDate: null,
    );
    await accounts.create(first);
    await accounts.create(second);
    final home = DriftDataRepository(database);
    await home.loadForAccount(first.phone);
    await (database.update(database.memberRows)
          ..where((row) => row.accountPhone.equals(first.phone)))
        .write(const MemberRowsCompanion(points: Value(420000)));
    await (database.update(database.memberRows)
          ..where((row) => row.accountPhone.equals(second.phone)))
        .write(const MemberRowsCompanion(points: Value(910000)));
    final auth = LocalAuthRepository(
      accountStore: accounts,
      sessionStore: MemoryAuthSessionStore(),
      delay: (_) async {},
    );

    await auth.login(first.phone, fakeOtpCode);
    final firstSession = await _value(auth.currentSession());
    final firstData = await home.loadForAccount(firstSession!.phone);
    expect(
      firstData,
      isA<Success>(),
      reason: firstData.fold(
        (_) => '',
        (failure) => '${failure.message}: ${failure.cause}',
      ),
    );
    expect((firstData as Success).value.member.points, 420000);
    await auth.logout();
    await auth.login(second.phone, fakeOtpCode);
    final secondSession = await _value(auth.currentSession());
    final secondData = await home.loadForAccount(secondSession!.phone);

    expect(secondSession.phone, second.phone);
    expect((secondData as Success).value.member.points, 910000);
  });
}

Future<T> _value<T>(Future<Result<T>> result) async => (await result).fold(
  (value) => value,
  (failure) => throw StateError(failure.message),
);

class _FailingSessionStore implements AuthSessionStore {
  @override
  Future<AuthUser?> read() async => null;

  @override
  Future<void> write(AuthUser user) async => throw StateError('write failed');

  @override
  Future<void> clear() async {}
}
