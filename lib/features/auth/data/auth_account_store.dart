import 'package:drift/drift.dart';
import 'package:jdonuts/core/storage/app_database.dart';

import '../domain/auth_repository.dart';

abstract interface class AuthAccountStore {
  Future<AuthUser?> find(String phone);
  Future<bool> contains(String phone);
  Future<void> save(AuthUser user);
  Future<void> delete(String phone);
}

class DriftAuthAccountStore implements AuthAccountStore {
  const DriftAuthAccountStore(this._database);

  final AppDatabase _database;

  @override
  Future<AuthUser?> find(String phone) async {
    final row = await (_database.select(
      _database.authAccountRows,
    )..where((account) => account.phone.equals(phone))).getSingleOrNull();
    if (row == null) return null;
    final birthMillis = row.birthDateMillis;
    return AuthUser(
      phone: row.phone,
      firstName: row.firstName,
      lastName: row.lastName,
      birthDate: birthMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(birthMillis),
    );
  }

  @override
  Future<bool> contains(String phone) async => await find(phone) != null;

  @override
  Future<void> save(AuthUser user) async {
    await _database
        .into(_database.authAccountRows)
        .insertOnConflictUpdate(
          AuthAccountRowsCompanion.insert(
            phone: user.phone,
            firstName: user.firstName,
            lastName: user.lastName,
            birthDateMillis: Value(user.birthDate?.millisecondsSinceEpoch),
          ),
        );
  }

  @override
  Future<void> delete(String phone) async {
    await (_database.delete(
      _database.authAccountRows,
    )..where((account) => account.phone.equals(phone))).go();
  }
}

class MemoryAuthAccountStore implements AuthAccountStore {
  final Map<String, AuthUser> _users = {};

  @override
  Future<AuthUser?> find(String phone) async => _users[phone];

  @override
  Future<bool> contains(String phone) async => _users.containsKey(phone);

  @override
  Future<void> save(AuthUser user) async => _users[user.phone] = user;

  @override
  Future<void> delete(String phone) async => _users.remove(phone);
}
