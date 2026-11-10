import '../../../core/result/result.dart';
import '../domain/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({
    Future<void> Function(Duration)? delay,
    Set<String>? registered,
  }) : _delay = delay ?? Future<void>.delayed,
       _registered = registered ?? {'95987654321'};
  final Future<void> Function(Duration) _delay;
  final Set<String> _registered;
  AuthUser? _session;
  final Map<String, AuthUser> _users = {};

  @override
  Future<bool> hasSession() async => _session != null;
  @override
  Future<bool> isRegistered(String phone) async =>
      _registered.contains(phone) || _users.containsKey(phone);
  @override
  Future<Result<AuthUser>> login(String phone, String code) async {
    await _delay(const Duration(seconds: 1));
    if (code != '123456')
      return const Error(AuthFailure('That code is not correct.'));
    if (!_registered.contains(phone) && !_users.containsKey(phone))
      return const Error(
        AuthFailure('This number is new. Register to continue.'),
      );
    final user =
        _users[phone] ??
        AuthUser(
          phone: phone,
          firstName: 'Hania',
          lastName: '',
          birthDate: null,
        );
    _session = user;
    return Success(user);
  }

  @override
  Future<Result<AuthUser>> register(AuthUser user, String code) async {
    await _delay(const Duration(seconds: 1));
    if (code != '123456')
      return const Error(AuthFailure('That code is not correct.'));
    _users[user.phone] = user;
    _registered.add(user.phone);
    _session = user;
    return Success(user);
  }

  @override
  Future<void> remember(AuthUser user) async => _session = user;
  @override
  Future<void> logout() async => _session = null;
}
