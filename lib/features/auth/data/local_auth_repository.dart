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
       _registered = registered ?? {'95987654321'};

  static const _requestLatency = Duration(seconds: 1);
  final AuthSessionStore _sessionStore;
  final AuthAccountStore _accountStore;
  final Future<void> Function(Duration) _delay;
  final Set<String> _registered;
  final Set<String> _verifiedNumbers = {};
  final Map<String, AuthUser> _registrationProfiles = {};
  AuthUser? _session;

  @override
  Future<bool> hasSession() async {
    _session ??= await _sessionStore.read();
    return _session != null;
  }

  @override
  Future<bool> isRegistered(String phone) async =>
      _registered.contains(phone) || await _accountStore.contains(phone);

  @override
  Future<Result<bool>> requestOtp(String phone) async {
    await _delay(_requestLatency);
    return const Success(true);
  }

  @override
  Future<Result<bool>> verifyOtp(String phone, String code) async {
    await _delay(_requestLatency);
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
    await _delay(_requestLatency);
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
    await _delay(_requestLatency);
    if (code != fakeOtpCode) {
      return const Error(
        AuthFailure(
          AuthFailureCode.incorrectCode,
          'Incorrect verification code.',
        ),
      );
    }
    final storedUser = await _accountStore.find(phone);
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
    await _delay(_requestLatency);
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
      return Error(StorageFailure('Could not save the session: $error'));
    }
    _registered.add(user.phone);
    _verifiedNumbers.remove(user.phone);
    _registrationProfiles.remove(user.phone);
    _session = user;
    return Success(user);
  }

  @override
  Future<void> logout() async {
    await _sessionStore.clear();
    _session = null;
  }

  AuthUser _sampleMember(String phone) =>
      AuthUser(phone: phone, firstName: 'Hania', lastName: '', birthDate: null);
}
