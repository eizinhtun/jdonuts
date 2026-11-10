import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class MemberRows extends Table {
  TextColumn get id => text()();
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

@DriftDatabase(
  tables: [
    MemberRows,
    ProductRows,
    BannerRows,
    SectionRows,
    ShopRows,
    ChallengeRows,
    AuthAccountRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 1 && to >= 1) await migrator.createAll();
      if (from < 2 && to >= 2) {
        await migrator.addColumn(memberRows, memberRows.image);
      }
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/jdonuts.sqlite');
  return NativeDatabase.createInBackground(file);
});
