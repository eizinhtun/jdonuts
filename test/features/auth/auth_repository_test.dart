import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';

void main() {
  group('LocalAuthRepository', () {
    test('request and verification use the fake code', () async {
      final repo = LocalAuthRepository(
        sessionStore: MemoryAuthSessionStore(),
        delay: (_) async {},
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
      expect(await _value(repo.hasSession()), isTrue);
      expect(await _value(repo.isRegistered(user.phone)), isTrue);
      expect(await _value(repo.logout()), isTrue);
      expect(await _value(repo.hasSession()), isFalse);
    });

    test(
      'returning number logs in and an unknown number is rejected',
      () async {
        final repo = LocalAuthRepository(
          sessionStore: MemoryAuthSessionStore(),
          delay: (_) async {},
          accountStore: MemoryAuthAccountStore(users: [_demoUser]),
        );
        final unknown = await repo.login('95911111111', fakeOtpCode);
        expect(unknown, isA<Error<AuthUser>>());
        expect((unknown as Error<AuthUser>).failure, isA<AuthFailure>());
        final returning = await repo.login('95987654321', fakeOtpCode);
        expect(returning, isA<Success<AuthUser>>());
        expect(await _value(repo.hasSession()), isTrue);
      },
    );

    test('a session without a matching account is cleared safely', () async {
      final sessions = MemoryAuthSessionStore();
      await sessions.write(_demoUser);
      final repo = LocalAuthRepository(
        sessionStore: sessions,
        delay: (_) async {},
        accountStore: MemoryAuthAccountStore(),
      );

      final session = await repo.currentSession();
      expect(session, isA<Success<AuthUser?>>());
      expect((session as Success<AuthUser?>).value, isNull);
      expect(await sessions.read(), isNull);
      expect(await _value(repo.hasSession()), isFalse);
    });

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

    test('service delay failures return a typed recoverable failure', () async {
      final repo = LocalAuthRepository(
        sessionStore: MemoryAuthSessionStore(),
        delay: (_) async => throw StateError('offline'),
      );

      final result = await repo.requestOtp('95987654321');
      expect(result, isA<Error<bool>>());
      final failure = (result as Error<bool>).failure;
      expect(
        failure,
        isA<AuthFailure>().having(
          (failure) => failure.code,
          'code',
          AuthFailureCode.serviceUnavailable,
        ),
      );
      expect(failure.message, isNot(contains('offline')));
      expect(failure.cause, isA<StateError>());
      expect(failure.stackTrace, isNotNull);
    });

    test(
      'failed sign-in storage does not create an authenticated session',
      () async {
        final sessions = _TestSessionStore(failWrite: true);
        final repo = LocalAuthRepository(
          sessionStore: sessions,
          delay: (_) async {},
          accountStore: MemoryAuthAccountStore(users: [_demoUser]),
        );

        final result = await repo.login('95987654321', fakeOtpCode);
        expect(result, isA<Error<AuthUser>>());
        final failure = (result as Error<AuthUser>).failure;
        expect(failure, isA<StorageFailure>());
        expect(failure.message, isNot(contains('session storage unavailable')));
        expect(failure.cause, isA<StateError>());
        expect(failure.stackTrace, isNotNull);
        expect(await _value(repo.hasSession()), isFalse);
      },
    );

    test(
      'failed registration session write rolls back the local account',
      () async {
        final sessions = _TestSessionStore(failWrite: true);
        final repo = LocalAuthRepository(
          sessionStore: sessions,
          delay: (_) async {},
        );
        const user = AuthUser(
          phone: '95912345678',
          firstName: 'May',
          lastName: '',
          birthDate: null,
        );

        await repo.verifyOtp(user.phone, fakeOtpCode);
        await repo.saveRegistrationProfile(user);
        final result = await repo.register(
          AuthUser(
            phone: user.phone,
            firstName: user.firstName,
            lastName: user.lastName,
            birthDate: DateTime(2000, 1, 1),
          ),
        );

        expect(result, isA<Error<AuthUser>>());
        expect(await _value(repo.isRegistered(user.phone)), isFalse);
        expect(await _value(repo.hasSession()), isFalse);
      },
    );

    test(
      'logout failure preserves the current session and returns a failure',
      () async {
        final sessions = _TestSessionStore();
        final repo = LocalAuthRepository(
          sessionStore: sessions,
          delay: (_) async {},
          accountStore: MemoryAuthAccountStore(users: [_demoUser]),
        );
        await repo.login('95987654321', fakeOtpCode);
        sessions.failClear = true;

        final result = await repo.logout();

        expect(result, isA<Error<bool>>());
        expect(await _value(repo.hasSession()), isTrue);
      },
    );
  });
}

const _demoUser = AuthUser(
  phone: '95987654321',
  firstName: 'Hania',
  lastName: '',
  birthDate: null,
);

Future<T> _value<T>(Future<Result<T>> result) async => (await result).fold(
  (value) => value,
  (failure) => throw StateError(failure.message),
);

class _TestSessionStore implements AuthSessionStore {
  _TestSessionStore({this.failWrite = false});

  AuthUser? user;
  bool failWrite;
  bool failClear = false;

  @override
  Future<AuthUser?> read() async => user;

  @override
  Future<void> write(AuthUser value) async {
    if (failWrite) throw StateError('write failed');
    user = value;
  }

  @override
  Future<void> clear() async {
    if (failClear) throw StateError('clear failed');
    user = null;
  }
}
