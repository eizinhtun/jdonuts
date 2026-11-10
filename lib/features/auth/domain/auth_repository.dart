import '../../../core/result/result.dart';

class AuthUser {
  const AuthUser({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });
  final String phone, firstName, lastName;
  final DateTime? birthDate;
}

abstract interface class AuthRepository {
  Future<bool> hasSession();
  Future<bool> isRegistered(String phone);
  Future<Result<AuthUser>> login(String phone, String code);
  Future<Result<AuthUser>> register(AuthUser user, String code);
  Future<void> logout();
  Future<void> remember(AuthUser user);
}
