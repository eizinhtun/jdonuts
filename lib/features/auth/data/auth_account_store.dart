import 'package:drift/drift.dart';
import 'package:jdonuts/core/storage/app_database.dart';

import '../domain/auth_repository.dart';

abstract interface class AuthAccountStore {
  Future<AuthUser?> find(String phone);
  Future<bool> contains(String phone);
  Future<void> create(AuthUser user);
  Future<void> delete(String phone);
}

class DuplicateAuthAccount implements Exception {
  const DuplicateAuthAccount();
}

class DriftAuthAccountStore implements AuthAccountStore {
  const DriftAuthAccountStore(this._database, {this.beforeRead});

  final AppDatabase _database;
  final Future<void> Function()? beforeRead;

  @override
  Future<AuthUser?> find(String phone) async {
    await beforeRead?.call();
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
  Future<void> create(AuthUser user) async {
    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.authAccountRows)
                ..where((account) => account.phone.equals(user.phone)))
              .getSingleOrNull();
      if (existing != null) throw const DuplicateAuthAccount();

      await _database
          .into(_database.authAccountRows)
          .insert(
            AuthAccountRowsCompanion.insert(
              phone: user.phone,
              firstName: user.firstName,
              lastName: user.lastName,
              birthDateMillis: Value(user.birthDate?.millisecondsSinceEpoch),
            ),
          );
      await _database
          .into(_database.memberRows)
          .insert(
            MemberRowsCompanion.insert(
              id: 'member-${user.phone}',
              accountPhone: Value(user.phone),
              name: _displayName(user),
              tier: _defaultMemberTier,
              points: _defaultMemberPoints,
              pointsToGold: _defaultPointsToGold,
              notifications: _defaultNotifications,
              image: const Value(_defaultMemberImage),
            ),
          );
      final challenges = await _database.select(_database.challengeRows).get();
      for (final challenge in challenges) {
        await _database
            .into(_database.memberChallengeRows)
            .insert(
              MemberChallengeRowsCompanion.insert(
                accountPhone: user.phone,
                challengeId: challenge.id,
                progress: challenge.progress,
              ),
            );
      }
    });
  }

  @override
  Future<void> delete(String phone) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.memberChallengeRows,
      )..where((challenge) => challenge.accountPhone.equals(phone))).go();
      await (_database.delete(
        _database.memberRows,
      )..where((member) => member.accountPhone.equals(phone))).go();
      await (_database.delete(
        _database.authAccountRows,
      )..where((account) => account.phone.equals(phone))).go();
    });
  }
}

class MemoryAuthAccountStore implements AuthAccountStore {
  MemoryAuthAccountStore({Iterable<AuthUser> users = const []})
    : _users = {for (final user in users) user.phone: user};

  final Map<String, AuthUser> _users;

  @override
  Future<AuthUser?> find(String phone) async => _users[phone];

  @override
  Future<bool> contains(String phone) async => _users.containsKey(phone);

  @override
  Future<void> create(AuthUser user) async {
    if (_users.containsKey(user.phone)) throw const DuplicateAuthAccount();
    _users[user.phone] = user;
  }

  @override
  Future<void> delete(String phone) async => _users.remove(phone);
}

const _defaultMemberTier = 'Silver';
const _defaultMemberPoints = 680000;
const _defaultPointsToGold = 500;
const _defaultNotifications = 2;
const _defaultMemberImage = 'member.svg';

String _displayName(AuthUser user) =>
    '${user.firstName.trim()} ${user.lastName.trim()}'.trim();
