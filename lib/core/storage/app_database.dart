import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

const _previousDemoMemberPoints = 680000;
const _currentDemoMemberPoints = 1000000;
const _displayedDemoMemberPoints = 680000;

class MemberRows extends Table {
  TextColumn get id => text()();
  TextColumn get accountPhone => text().nullable()();
  TextColumn get name => text()();
  TextColumn get tier => text()();
  IntColumn get points => integer()();
  IntColumn get pointsToGold => integer()();
  IntColumn get notifications => integer()();
  TextColumn get image => text().withDefault(const Constant('member.svg'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ProductRows extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get priceMmk => integer()();
  BoolColumn get isNew => boolean()();
  IntColumn get discountPercent => integer().nullable()();
  TextColumn get image => text()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class BannerRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get image => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SectionRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get productIdsJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ShopRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class ChallengeRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get progress => integer()();
  IntColumn get target => integer()();
  IntColumn get points => integer()();
  TextColumn get kind => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AuthAccountRows extends Table {
  TextColumn get phone => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  IntColumn get birthDateMillis => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {phone};
}

class MemberChallengeRows extends Table {
  TextColumn get accountPhone => text()();
  TextColumn get challengeId => text()();
  IntColumn get progress => integer()();

  @override
  Set<Column<Object>> get primaryKey => {accountPhone, challengeId};
}

@DriftDatabase(
  tables: [
    MemberRows,
    ProductRows,
    BannerRows,
    SectionRows,
    ShopRows,
    ChallengeRows,
    AuthAccountRows,
    MemberChallengeRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement('''
        CREATE UNIQUE INDEX member_rows_account_phone
        ON member_rows (account_phone)
      ''');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 1 && to >= 1) await migrator.createAll();
      if (from < 2 && to >= 2) {
        await migrator.addColumn(memberRows, memberRows.image);
      }
      if (from < 3 && to >= 3) {
        await customStatement('''
          UPDATE product_rows
          SET image = CASE id
            WHEN 'coconut' THEN 'coconut-donut.png'
            WHEN 'strawberry' THEN 'chocolate-donut.png'
            WHEN 'coffee' THEN 'dalgona-coffee.png'
            WHEN 'romance-box' THEN 'seasonal-donut-box.jpg'
            WHEN 'family-box' THEN 'seasonal-donut-box.jpg'
            ELSE image
          END
          WHERE (id = 'coconut' AND image = 'coconut.svg')
            OR (id = 'strawberry' AND image = 'strawberry.svg')
            OR (id = 'coffee' AND image = 'coffee.svg')
            OR (id = 'romance-box' AND image = 'box.svg')
            OR (id = 'family-box' AND image = 'box.svg')
        ''');
        await customStatement(
          "UPDATE banner_rows SET image = 'shop-banner.jpg' WHERE image = 'banner.svg'",
        );
      }
      if (from < 4 && to >= 4) {
        await customStatement('''
          UPDATE member_rows
          SET points = $_currentDemoMemberPoints
          WHERE id = 'member-1' AND points = $_previousDemoMemberPoints
        ''');
      }
      if (from < 5 && to >= 5) {
        await customStatement('''
          UPDATE member_rows
          SET points = $_displayedDemoMemberPoints
          WHERE id = 'member-1' AND points = $_currentDemoMemberPoints
        ''');
      }
      if (from < 6 && to >= 6) {
        await migrator.addColumn(memberRows, memberRows.accountPhone);
        await customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS member_rows_account_phone
          ON member_rows (account_phone)
        ''');
        final accountTable = await customSelect('''
          SELECT name FROM sqlite_master
          WHERE type = 'table' AND name = 'auth_account_rows'
        ''').getSingleOrNull();
        if (accountTable == null) {
          await migrator.createTable(authAccountRows);
        }
      }
      if (from < 7 && to >= 7) {
        final challengeProgressTable = await customSelect('''
          SELECT name FROM sqlite_master
          WHERE type = 'table' AND name = 'member_challenge_rows'
        ''').getSingleOrNull();
        if (challengeProgressTable == null) {
          await migrator.createTable(memberChallengeRows);
        }
      }
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/jdonuts.sqlite');
  return NativeDatabase.createInBackground(file);
});
