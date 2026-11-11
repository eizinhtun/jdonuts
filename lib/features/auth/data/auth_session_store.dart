import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_repository.dart';

abstract interface class AuthSessionStore {
  Future<AuthUser?> read();
  Future<void> write(AuthUser user);
  Future<void> clear();
}

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'jdonuts.auth.session.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<AuthUser?> read() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      final birthDate = json['birthDate'] as String?;
      return AuthUser(
        phone: json['phone'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        birthDate: birthDate == null ? null : DateTime.parse(birthDate),
      );
    } on Object {
      await _storage.delete(key: _sessionKey);
      rethrow;
    }
  }

  @override
  Future<void> write(AuthUser user) => _storage.write(
    key: _sessionKey,
    value: jsonEncode({
      'phone': user.phone,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'birthDate': user.birthDate?.toIso8601String(),
    }),
  );

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}

class MemoryAuthSessionStore implements AuthSessionStore {
  AuthUser? _user;

  @override
  Future<AuthUser?> read() async => _user;

  @override
  Future<void> write(AuthUser user) async => _user = user;

  @override
  Future<void> clear() async => _user = null;
}
