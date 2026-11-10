import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/home/data/local_data_repository.dart';
import 'package:jdonuts/features/home/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first load seeds every data group and the migration version', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftDataRepository(database);

    final result = await repository.load();
    expect(result, isA<Success<AppData>>());
    final data = (result as Success<AppData>).value;
    expect(data.member.points, 680000);
    expect(data.products, hasLength(5));
    expect(data.banners, hasLength(2));
    expect(data.sections, hasLength(3));
    expect(data.shops, hasLength(4));
    final seasonal = await repository.loadSectionProducts('seasonal');
    expect(
      seasonal.fold(
        (items) => items.map((item) => item.id).toList(),
        (_) => [],
      ),
      ['romance-box', 'family-box'],
    );
    expect(
      await repository.loadSectionProducts('missing'),
      isA<Error<List<Product>>>(),
    );
    expect(data.challenges, hasLength(3));

    expect(await database.select(database.memberRows).get(), hasLength(1));
    expect(await database.select(database.productRows).get(), hasLength(5));
    expect(await database.select(database.bannerRows).get(), hasLength(2));
    expect(await database.select(database.sectionRows).get(), hasLength(3));
    expect(await database.select(database.shopRows).get(), hasLength(4));
    expect(await database.select(database.challengeRows).get(), hasLength(3));
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data['user_version'], 2);
  });

  test('schema v1 upgrades member records with the bundled avatar default', () async {
    final database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (connection) {
          connection.execute(
            'CREATE TABLE member_rows ('
            'id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, '
            'tier TEXT NOT NULL, points INTEGER NOT NULL, '
            'points_to_gold INTEGER NOT NULL, notifications INTEGER NOT NULL)',
          );
          connection.execute(
            "INSERT INTO member_rows VALUES ('member-1', 'Hania', 'Silver', 680000, 500, 2)",
          );
          connection.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(database.close);

    final member = await database.select(database.memberRows).getSingle();
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(member.image, 'member.svg');
    expect(version.data['user_version'], 2);
  });

  test('overlapping first reads only seed each row once', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftDataRepository(database);

    final results = await Future.wait([repository.load(), repository.load()]);

    expect(results, everyElement(isA<Success<AppData>>()));
    expect(await database.select(database.memberRows).get(), hasLength(1));
    expect(await database.select(database.shopRows).get(), hasLength(4));
  });

  test(
    'subsequent reads use SQLite when the asset bundle is unavailable',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final initial = await DriftDataRepository(database).load();
      expect(initial, isA<Success<AppData>>());
      await (database.update(database.memberRows))
          .write(const MemberRowsCompanion(points: Value(681234)));

      final offlineRepository = DriftDataRepository(
        database,
        bundle: _UnavailableAssetBundle(),
      );
      final offline = await offlineRepository.load();
      expect(offline, isA<Success<AppData>>());
      expect((offline as Success<AppData>).value.member.points, 681234);
      expect(await database.select(database.shopRows).get(), hasLength(4));
    },
  );
}

class _UnavailableAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw StateError('The asset bundle is unavailable in this test.');
}
