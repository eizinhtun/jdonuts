import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';

void main() {
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
        registered: {},
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
        registered: {},
      );
      expect(await _value(relaunchedRepository.hasSession()), isTrue);
      expect(
        await relaunchedRepository.login(user.phone, fakeOtpCode),
        isA<Success<AuthUser>>(),
      );
      expect(await _value(relaunchedRepository.logout()), isTrue);
      expect(await _value(relaunchedRepository.hasSession()), isFalse);
    },
  );
}

Future<T> _value<T>(Future<Result<T>> result) async => (await result).fold(
  (value) => value,
  (failure) => throw StateError(failure.message),
);
