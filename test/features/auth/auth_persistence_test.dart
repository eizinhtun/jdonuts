import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';

void main() {
  test(
    'SQLite account and persisted session survive repository recreation',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final accounts = DriftAuthAccountStore(database);
      final sessions = MemoryAuthSessionStore();
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
        sessionStore: sessions,
        delay: (_) async {},
        registered: {},
      );
      expect(await relaunchedRepository.hasSession(), isTrue);
      expect(
        await relaunchedRepository.login(user.phone, fakeOtpCode),
        isA<Success<AuthUser>>(),
      );
      await relaunchedRepository.logout();
      expect(await relaunchedRepository.hasSession(), isFalse);
    },
  );
}
