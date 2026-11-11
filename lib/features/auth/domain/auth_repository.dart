import '../../../core/result/result.dart';

class AuthUser {
  const AuthUser({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
  });

  final String phone;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
}

abstract interface class AuthRepository {
  Future<Result<bool>> hasSession();
  Future<Result<AuthUser?>> currentSession();
  Future<Result<bool>> isRegistered(String phone);
  Future<Result<bool>> requestOtp(String phone);
  Future<Result<bool>> verifyOtp(String phone, String code);
  Future<Result<bool>> saveRegistrationProfile(AuthUser user);
  Future<Result<AuthUser>> login(String phone, String code);
  Future<Result<AuthUser>> register(AuthUser user);
  Future<Result<bool>> logout();
}
