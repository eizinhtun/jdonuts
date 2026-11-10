import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';

void main() {
  group('LocalAuthRepository', () {
    test('request and verification use the fake code', () async {
      final repo = LocalAuthRepository(
        sessionStore: MemoryAuthSessionStore(),
        delay: (_) async {},
        registered: {},
      );
      expect(await repo.requestOtp('95912345678'), isA<Success<bool>>());
      expect(await repo.verifyOtp('95912345678', '000000'), isA<Error<bool>>());
      expect(
        await repo.verifyOtp('95912345678', fakeOtpCode),
        isA<Success<bool>>(),
      );
    });

    test('registration requires a verified number and saved profile', () async {
      final repo = LocalAuthRepository(
        sessionStore: MemoryAuthSessionStore(),
        delay: (_) async {},
        registered: {},
      );
      final user = AuthUser(
        phone: '95912345678',
        firstName: 'May',
        lastName: '',
        birthDate: DateTime(2000, 1, 1),
      );
      expect(await repo.register(user), isA<Error<AuthUser>>());
      await repo.verifyOtp(user.phone, fakeOtpCode);
      expect(await repo.saveRegistrationProfile(user), isA<Success<bool>>());
      expect(await repo.register(user), isA<Success<AuthUser>>());
      expect(await repo.hasSession(), isTrue);
      expect(await repo.isRegistered(user.phone), isTrue);
      await repo.logout();
      expect(await repo.hasSession(), isFalse);
    });

    test(
      'returning number logs in and an unknown number is rejected',
      () async {
        final repo = LocalAuthRepository(
          sessionStore: MemoryAuthSessionStore(),
          delay: (_) async {},
        );
        final unknown = await repo.login('95911111111', fakeOtpCode);
        expect(unknown, isA<Error<AuthUser>>());
        expect((unknown as Error<AuthUser>).failure, isA<AuthFailure>());
        final returning = await repo.login('95987654321', fakeOtpCode);
        expect(returning, isA<Success<AuthUser>>());
        expect(await repo.hasSession(), isTrue);
      },
    );

    test('fake calls use the injectable latency', () async {
      final delays = <Duration>[];
      final repo = LocalAuthRepository(
        sessionStore: MemoryAuthSessionStore(),
        delay: (duration) async => delays.add(duration),
      );
      await repo.requestOtp('95987654321');
      await repo.login('95987654321', fakeOtpCode);
      expect(delays, [const Duration(seconds: 1), const Duration(seconds: 1)]);
    });
  });
}
