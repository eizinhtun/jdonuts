import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
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

    final profiles = await database.select(database.memberRows).get();
    expect(profiles, hasLength(1));
    expect(profiles.single.accountPhone, '95987654321');
    final demoAccount = await database
        .select(database.authAccountRows)
        .getSingle();
    expect(demoAccount.phone, '95987654321');
    expect(await database.select(database.productRows).get(), hasLength(5));
    expect(await database.select(database.bannerRows).get(), hasLength(2));
    expect(await database.select(database.sectionRows).get(), hasLength(3));
    expect(await database.select(database.shopRows).get(), hasLength(4));
    expect(await database.select(database.challengeRows).get(), hasLength(3));
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data['user_version'], 7);
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
            'CREATE TABLE product_rows (id TEXT NOT NULL PRIMARY KEY, image TEXT NOT NULL)',
          );
          connection.execute(
            'CREATE TABLE banner_rows (id TEXT NOT NULL PRIMARY KEY, image TEXT NOT NULL)',
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
    expect(member.points, 680000);
    expect(version.data['user_version'], 7);
  });

  test(
    'schema v2 upgrades bundled image paths without replacing records',
    () async {
      final database = AppDatabase.forTesting(
        NativeDatabase.memory(
          setup: (connection) {
            connection.execute(
              'CREATE TABLE member_rows ('
              'id TEXT NOT NULL PRIMARY KEY, points INTEGER NOT NULL)',
            );
            connection.execute(
              'CREATE TABLE product_rows ('
              'id TEXT NOT NULL PRIMARY KEY, code TEXT NOT NULL, '
              'name TEXT NOT NULL, price_mmk INTEGER NOT NULL, '
              'is_new INTEGER NOT NULL, discount_percent INTEGER, '
              'image TEXT NOT NULL, description TEXT NOT NULL)',
            );
            connection.execute(
              'CREATE TABLE banner_rows ('
              'id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, '
              'subtitle TEXT NOT NULL, image TEXT NOT NULL)',
            );
            connection.execute(
              "INSERT INTO product_rows VALUES "
              "('coconut', 'JD1', 'Coconut', 1, 1, NULL, 'coconut.svg', ''), "
              "('coffee', 'JD2', 'Coffee', 1, 1, NULL, 'coffee.svg', ''), "
              "('custom', 'JD3', 'Custom', 1, 0, NULL, 'custom.png', ''), "
              "('romance-box', 'JD4', 'Box', 1, 0, NULL, 'custom-box.png', '')",
            );
            connection.execute(
              "INSERT INTO banner_rows VALUES "
              "('banner-0', 'Shop', 'New', 'banner.svg'), "
              "('banner-1', 'Shop', 'New', 'banner.svg')",
            );
            connection.execute('PRAGMA user_version = 2');
          },
        ),
      );
      addTearDown(database.close);

      final products = await database.select(database.productRows).get();
      final banners = await database.select(database.bannerRows).get();

      expect(
        {for (final product in products) product.id: product.image},
        {
          'coconut': 'coconut-donut.png',
          'coffee': 'dalgona-coffee.png',
          'custom': 'custom.png',
          'romance-box': 'custom-box.png',
        },
      );

      expect(
        banners.map((banner) => banner.image),
        everyElement('shop-banner.jpg'),
      );
    },
  );

  test('schema v3 upgrades the untouched demo member to the current balance', () async {
    final database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (connection) {
          connection.execute(
            'CREATE TABLE member_rows ('
            'id TEXT NOT NULL PRIMARY KEY, points INTEGER NOT NULL)',
          );
          connection.execute(
            "INSERT INTO member_rows VALUES "
            "('member-1', 680000), ('member-2', 680000), ('member-3', 750000)",
          );
          connection.execute('PRAGMA user_version = 3');
        },
      ),
    );
    addTearDown(database.close);

    final members = await database
        .customSelect('SELECT id, points FROM member_rows ORDER BY id')
        .get();
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(
      {for (final row in members) row.data['id']: row.data['points']},
      {'member-1': 680000, 'member-2': 680000, 'member-3': 750000},
    );
    expect(version.data['user_version'], 7);
  });

  test('schema v4 changes only the untouched demo member total', () async {
    final database = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (connection) {
          connection.execute(
            'CREATE TABLE member_rows ('
            'id TEXT NOT NULL PRIMARY KEY, points INTEGER NOT NULL)',
          );
          connection.execute(
            "INSERT INTO member_rows VALUES "
            "('member-1', 1000000), ('member-2', 1000000), "
            "('member-3', 750000)",
          );
          connection.execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(database.close);

    final members = await database
        .customSelect('SELECT id, points FROM member_rows ORDER BY id')
        .get();
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(
      {for (final row in members) row.data['id']: row.data['points']},
      {'member-1': 680000, 'member-2': 1000000, 'member-3': 750000},
    );
    expect(version.data['user_version'], 7);
  });

  test('overlapping first reads only seed each row once', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftDataRepository(database);

    final results = await Future.wait([repository.load(), repository.load()]);

    expect(results, everyElement(isA<Success<AppData>>()));
    expect(await database.select(database.memberRows).get(), hasLength(1));
    expect(await database.select(database.authAccountRows).get(), hasLength(1));
    expect(await database.select(database.shopRows).get(), hasLength(4));
    expect(
      await database.select(database.memberChallengeRows).get(),
      hasLength(3),
    );
  });

  test(
    'account switching reads each persisted member profile by phone',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final accounts = DriftAuthAccountStore(database);
      final repository = DriftDataRepository(database);
      const first = AuthUser(
        phone: '95911111111',
        firstName: 'May',
        lastName: 'Aung',
        birthDate: null,
      );
      const second = AuthUser(
        phone: '95922222222',
        firstName: 'May',
        lastName: 'Aung',
        birthDate: null,
      );
      await accounts.create(first);
      await accounts.create(second);
      final initialFirstResult = await repository.loadForAccount(first.phone);
      expect(initialFirstResult, isA<Success<AppData>>());
      expect(
        await database.select(database.memberChallengeRows).get(),
        hasLength(9),
      );
      await (database.update(database.memberRows)
            ..where((member) => member.accountPhone.equals(first.phone)))
          .write(const MemberRowsCompanion(points: Value(600000)));
      await (database.update(database.memberRows)
            ..where((member) => member.accountPhone.equals(second.phone)))
          .write(const MemberRowsCompanion(points: Value(750000)));
      await (database.update(database.memberChallengeRows)..where(
            (row) =>
                row.accountPhone.equals(first.phone) &
                row.challengeId.equals('donut-4'),
          ))
          .write(const MemberChallengeRowsCompanion(progress: Value(2)));
      await (database.update(database.memberChallengeRows)..where(
            (row) =>
                row.accountPhone.equals(second.phone) &
                row.challengeId.equals('donut-4'),
          ))
          .write(const MemberChallengeRowsCompanion(progress: Value(1)));

      final firstResult = await repository.loadForAccount(first.phone);
      final secondResult = await repository.loadForAccount(second.phone);
      final repeatedFirstResult = await repository.loadForAccount(first.phone);

      expect(firstResult, isA<Success<AppData>>());
      expect(secondResult, isA<Success<AppData>>());
      expect(repeatedFirstResult, isA<Success<AppData>>());
      final firstData = (firstResult as Success<AppData>).value;
      final secondData = (secondResult as Success<AppData>).value;
      final repeatedData = (repeatedFirstResult as Success<AppData>).value;
      expect(firstData.member.name, 'May Aung');
      expect(secondData.member.name, 'May Aung');
      expect(firstData.member.id, isNot(secondData.member.id));
      expect(firstData.member.points, 600000);
      expect(secondData.member.points, 750000);
      expect(firstData.challenges.first.progress, 2);
      expect(secondData.challenges.first.progress, 1);
      expect(repeatedData.member.points, 600000);
      expect(
        await database.select(database.authAccountRows).get(),
        hasLength(3),
      );
      expect(await database.select(database.memberRows).get(), hasLength(3));
      expect(repeatedData.challenges.first.progress, 2);
    },
  );

  test(
    'a registered account with a missing profile returns a recoverable error',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      const user = AuthUser(
        phone: '95933333333',
        firstName: 'May',
        lastName: 'Aung',
        birthDate: null,
      );
      final accounts = DriftAuthAccountStore(database);
      await accounts.create(user);
      await (database.delete(
        database.memberRows,
      )..where((member) => member.accountPhone.equals(user.phone))).go();

      final result = await DriftDataRepository(database)
          .loadForAccount(user.phone);

      expect(result, isA<Error<AppData>>());
      expect((result as Error<AppData>).failure, isA<StorageFailure>());
      expect(await accounts.find(user.phone), isNotNull);
      expect(
        await (database.select(
          database.memberRows,
        )..where((member) => member.accountPhone.equals(user.phone))).get(),
        isEmpty,
      );
    },
  );

  test(
    'subsequent reads use SQLite when the asset bundle is unavailable',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final initial = await DriftDataRepository(database).load();
      expect(initial, isA<Success<AppData>>());
      await (database.update(database.memberRows))
          .write(const MemberRowsCompanion(points: Value(681234)));
      await (database.update(
        database.productRows,
      )..where((row) => row.id.equals('coconut'))).write(
        const ProductRowsCompanion(name: Value('Locally edited coconut donut')),
      );

      final offlineRepository = DriftDataRepository(
        database,
        bundle: _UnavailableAssetBundle(),
      );
      final offline = await offlineRepository.load();
      final repeated = await offlineRepository.load();
      expect(offline, isA<Success<AppData>>());
      final cachedData = (offline as Success<AppData>).value;
      expect(cachedData.member.points, 681234);
      expect(
        cachedData.product('coconut')?.name,
        'Locally edited coconut donut',
      );
      expect(repeated, isA<Success<AppData>>());
      expect((repeated as Success<AppData>).value.products, hasLength(5));
      expect(await database.select(database.shopRows).get(), hasLength(4));
    },
  );
}

class _UnavailableAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw StateError('The asset bundle is unavailable in this test.');
}
