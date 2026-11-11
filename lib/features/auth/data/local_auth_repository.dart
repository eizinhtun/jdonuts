import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';
import 'auth_account_store.dart';
import 'auth_session_store.dart';

const fakeOtpCode = '123456';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({
    Future<void> Function(Duration)? delay,
    Set<String>? registered,
    AuthSessionStore? sessionStore,
    AuthAccountStore? accountStore,
  }) : _sessionStore = sessionStore ?? SecureAuthSessionStore(),
       _accountStore = accountStore ?? MemoryAuthAccountStore(),
       _delay = delay ?? ((duration) => Future<void>.delayed(duration)),
       _registered = Set<String>.of(registered ?? {'95987654321'});

  static const _requestLatency = Duration(seconds: 1);
  final AuthSessionStore _sessionStore;
  final AuthAccountStore _accountStore;
  final Future<void> Function(Duration) _delay;
  final Set<String> _registered;
  final Set<String> _verifiedNumbers = {};
  final Map<String, AuthUser> _registrationProfiles = {};
  AuthUser? _session;

  @override
  Future<Result<bool>> hasSession() async {
    try {
      _session ??= await _sessionStore.read();
      return Success(_session != null);
    } on Object catch (error) {
      return Error(StorageFailure('Could not restore the session: $error'));
    }
  }

  @override
  Future<Result<bool>> isRegistered(String phone) async {
    try {
      return Success(
        _registered.contains(phone) || await _accountStore.contains(phone),
      );
    } on Object catch (error) {
      return Error(StorageFailure('Could not check the saved account: $error'));
    }
  }

  @override
  Future<Result<bool>> requestOtp(String phone) async {
    try {
      await _delay(_requestLatency);
      return const Success(true);
    } on Object catch (error) {
      return Error(
        AuthFailure(
          AuthFailureCode.serviceUnavailable,
          'Could not request a verification code: $error',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> verifyOtp(String phone, String code) async {
    try {
      await _delay(_requestLatency);
    } on Object catch (error) {
      return Error(
        AuthFailure(
          AuthFailureCode.serviceUnavailable,
          'Could not verify the code: $error',
        ),
      );
    }
    if (code != fakeOtpCode) {
      return const Error(
        AuthFailure(
          AuthFailureCode.incorrectCode,
          'Incorrect verification code.',
        ),
      );
    }
    _verifiedNumbers.add(phone);
    return const Success(true);
  }

  @override
  Future<Result<bool>> saveRegistrationProfile(AuthUser user) async {
    try {
      await _delay(_requestLatency);
    } on Object catch (error) {
      return Error(
        AuthFailure(
          AuthFailureCode.serviceUnavailable,
          'Could not save the profile: $error',
        ),
      );
    }
    if (!_verifiedNumbers.contains(user.phone)) {
      return const Error(
        AuthFailure(
          AuthFailureCode.unverifiedNumber,
          'Verify the number first.',
        ),
      );
    }
    _registrationProfiles[user.phone] = user;
    return const Success(true);
  }

  @override
  Future<Result<AuthUser>> login(String phone, String code) async {
    try {
      await _delay(_requestLatency);
    } on Object catch (error) {
      return Error(
        AuthFailure(
          AuthFailureCode.serviceUnavailable,
          'Could not sign in: $error',
        ),
      );
    }
    if (code != fakeOtpCode) {
      return const Error(
        AuthFailure(
          AuthFailureCode.incorrectCode,
          'Incorrect verification code.',
        ),
      );
    }
    AuthUser? storedUser;
    try {
      storedUser = await _accountStore.find(phone);
    } on Object catch (error) {
      return Error(StorageFailure('Could not load the saved account: $error'));
    }
    if (!_registered.contains(phone) && storedUser == null) {
      return const Error(
        AuthFailure(AuthFailureCode.unknownNumber, 'Number is not registered.'),
      );
    }
    final user = storedUser ?? _sampleMember(phone);
    try {
      await _sessionStore.write(user);
    } on Object catch (error) {
      return Error(StorageFailure('Could not save the session: $error'));
    }
    _session = user;
    return Success(user);
  }

  @override
  Future<Result<AuthUser>> register(AuthUser user) async {
    try {
      await _delay(_requestLatency);
    } on Object catch (error) {
      return Error(
        AuthFailure(
          AuthFailureCode.serviceUnavailable,
          'Could not complete registration: $error',
        ),
      );
    }
    if (!_verifiedNumbers.contains(user.phone) ||
        !_registrationProfiles.containsKey(user.phone) ||
        user.birthDate == null) {
      return const Error(
        AuthFailure(
          AuthFailureCode.registrationIncomplete,
          'Complete the registration steps first.',
        ),
      );
    }
    try {
      await _accountStore.save(user);
    } on Object catch (error) {
      return Error(StorageFailure('Could not save the account: $error'));
    }
    try {
      await _sessionStore.write(user);
    } on Object catch (error) {
      try {
        await _accountStore.delete(user.phone);
      } on Object catch (rollbackError) {
        return Error(
          StorageFailure(
            'Could not save the session or undo the account write: $rollbackError',
          ),
        );
      }
      return Error(StorageFailure('Could not save the session: $error'));
    }
    _registered.add(user.phone);
    _verifiedNumbers.remove(user.phone);
    _registrationProfiles.remove(user.phone);
    _session = user;
    return Success(user);
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      await _sessionStore.clear();
      _session = null;
      return const Success(true);
    } on Object catch (error) {
      return Error(StorageFailure('Could not clear the session: $error'));
    }
  }

  AuthUser _sampleMember(String phone) =>
      AuthUser(phone: phone, firstName: 'Hania', lastName: '', birthDate: null);
}
