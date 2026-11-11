import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:jdonuts/core/result/result.dart';

import '../../../core/storage/app_database.dart';
import '../domain/home_repository.dart';
import '../domain/models.dart';

const _demoAccountPhone = '95987654321';

class DriftDataRepository implements HomeRepository {
  DriftDataRepository(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  @override
  Future<Result<AppData>> load() => _load(_demoAccountPhone);

  @override
  Future<Result<AppData>> loadForAccount(String accountPhone) =>
      _load(accountPhone);

  Future<Result<AppData>> _load(String accountPhone) async {
    try {
      await _seedOnFirstLaunch();
      final data = await _readDatabase(accountPhone: accountPhone);
      return data == null
          ? const Error(
              StorageFailure(
                'The signed-in account has no membership profile.',
              ),
            )
          : Success(data);
    } on Object catch (error, stackTrace) {
      return Error(
        StorageFailure(
          'Could not read local data.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<AppData>> refresh() => _load(_demoAccountPhone);

  @override
  Future<Result<AppData>> refreshForAccount(String accountPhone) =>
      _load(accountPhone);

  @override
  Future<Result<List<Product>>> loadSectionProducts(String sectionId) async {
    try {
      await _seedOnFirstLaunch();
      final section = await (_database.select(
        _database.sectionRows,
      )..where((row) => row.id.equals(sectionId))).getSingleOrNull();
      if (section == null) {
        return const Error(StorageFailure('The requested section is missing.'));
      }
      final ids = (jsonDecode(section.productIdsJson) as List).cast<String>();
      if (ids.isEmpty) return const Success([]);
      final rows = await (_database.select(
        _database.productRows,
      )..where((row) => row.id.isIn(ids))).get();
      final byId = {for (final row in rows) row.id: _productFromRow(row)};
      return Success(ids.map((id) => byId[id]).whereType<Product>().toList());
    } on Object catch (error, stackTrace) {
      return Error(
        StorageFailure(
          'Could not read this section.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _seedOnFirstLaunch() async {
    final catalog = await (_database.select(
      _database.productRows,
    )..limit(1)).getSingleOrNull();
    final demoAccount =
        await (_database.select(_database.authAccountRows)
              ..where((account) => account.phone.equals(_demoAccountPhone)))
            .getSingleOrNull();
    final demoProfile =
        await (_database.select(
              _database.memberRows,
            )..where((member) => member.accountPhone.equals(_demoAccountPhone)))
            .getSingleOrNull();
    final accountWithoutChallengeProgress = await _database.customSelect('''
      SELECT member.account_phone
      FROM member_rows AS member
      CROSS JOIN challenge_rows AS challenge
      LEFT JOIN member_challenge_rows AS progress
        ON progress.account_phone = member.account_phone
       AND progress.challenge_id = challenge.id
      WHERE member.account_phone IS NOT NULL
        AND progress.challenge_id IS NULL
      LIMIT 1
    ''').getSingleOrNull();
    if (catalog != null &&
        demoAccount != null &&
        demoProfile != null &&
        accountWithoutChallengeProgress == null) {
      return;
    }

    final json = jsonDecode(
      await _bundle.loadString('assets/data/seed.json'),
    ) as Map<String, dynamic>;
    final seed = AppData.fromJson(json);
    final demo = json['demoAccount'] as Map<String, dynamic>;
    await _database.transaction(() async {
      final catalogInsideTransaction = await (_database.select(
        _database.productRows,
      )..limit(1)).getSingleOrNull();
      if (catalogInsideTransaction == null) {
        await _seedCatalog(seed);
      }
      await _ensureMembershipProfiles(seed, demo);
    });
  }

  Future<void> _seedCatalog(AppData seed) async {
    for (final product in seed.products) {
      await _database
          .into(_database.productRows)
          .insert(
            ProductRowsCompanion.insert(
              id: product.id,
              code: product.code,
              name: product.name,
              priceMmk: product.priceMmk,
              isNew: product.isNew,
              discountPercent: Value(product.discountPercent),
              image: product.image,
              description: product.description,
            ),
          );
    }
    for (var index = 0; index < seed.banners.length; index++) {
      final banner = seed.banners[index];
      await _database
          .into(_database.bannerRows)
          .insert(
            BannerRowsCompanion.insert(
              id: 'banner-$index',
              title: banner.title,
              subtitle: banner.subtitle,
              image: banner.image,
            ),
          );
    }
    for (final section in seed.sections) {
      await _database
          .into(_database.sectionRows)
          .insert(
            SectionRowsCompanion.insert(
              id: section.id,
              title: section.title,
              productIdsJson: jsonEncode(section.productIds),
            ),
          );
    }
    for (final shop in seed.shops) {
      await _database
          .into(_database.shopRows)
          .insert(ShopRowsCompanion.insert(name: shop));
    }
    for (final challenge in seed.challenges) {
      await _database
          .into(_database.challengeRows)
          .insert(
            ChallengeRowsCompanion.insert(
              id: challenge.id,
              title: challenge.title,
              progress: challenge.progress,
              target: challenge.target,
              points: challenge.points,
              kind: challenge.kind,
            ),
          );
    }
  }

  Future<void> _ensureMembershipProfiles(
    AppData seed,
    Map<String, dynamic> demo,
  ) async {
    final demoPhone = demo['phone'] as String;
    final existingDemo = await (_database.select(
      _database.authAccountRows,
    )..where((account) => account.phone.equals(demoPhone))).getSingleOrNull();
    if (existingDemo == null) {
      await _database
          .into(_database.authAccountRows)
          .insert(
            AuthAccountRowsCompanion.insert(
              phone: demoPhone,
              firstName: demo['firstName'] as String,
              lastName: demo['lastName'] as String,
              birthDateMillis: const Value(null),
            ),
          );
    }

    final demoUser = await (_database.select(
      _database.authAccountRows,
    )..where((account) => account.phone.equals(demoPhone))).getSingle();
    final demoProfile =
        await (_database.select(_database.memberRows)
              ..where((member) => member.accountPhone.equals(demoPhone)))
            .getSingleOrNull();
    if (demoProfile == null) {
      final unlinkedSeedProfile = await (_database.select(
        _database.memberRows,
      )..where((member) => member.id.equals(seed.member.id))).getSingleOrNull();
      if (unlinkedSeedProfile != null &&
          unlinkedSeedProfile.accountPhone == null) {
        await (_database.update(
          _database.memberRows,
        )..where((member) => member.id.equals(seed.member.id))).write(
          MemberRowsCompanion(
            accountPhone: Value(demoPhone),
            name: Value(
              _accountDisplayName(demoUser.firstName, demoUser.lastName),
            ),
          ),
        );
      } else {
        await _database
            .into(_database.memberRows)
            .insert(
              MemberRowsCompanion.insert(
                id: seed.member.id,
                accountPhone: Value(demoPhone),
                name: _accountDisplayName(
                  demoUser.firstName,
                  demoUser.lastName,
                ),
                tier: seed.member.tier,
                points: seed.member.points,
                pointsToGold: seed.member.pointsToGold,
                notifications: seed.member.notifications,
                image: Value(seed.member.image),
              ),
            );
      }
    }
    final profiles = await (_database.select(
      _database.memberRows,
    )..where((member) => member.accountPhone.isNotNull())).get();
    for (final profile in profiles) {
      await _ensureChallengeProgress(profile.accountPhone!);
    }
  }

  Future<void> _ensureChallengeProgress(String accountPhone) async {
    final templates = await _database.select(_database.challengeRows).get();
    final existing = await (_database.select(
      _database.memberChallengeRows,
    )..where((row) => row.accountPhone.equals(accountPhone))).get();
    final existingIds = existing.map((row) => row.challengeId).toSet();
    for (final challenge in templates) {
      if (existingIds.contains(challenge.id)) continue;
      await _database
          .into(_database.memberChallengeRows)
          .insert(
            MemberChallengeRowsCompanion.insert(
              accountPhone: accountPhone,
              challengeId: challenge.id,
              progress: challenge.progress,
            ),
          );
    }
  }

  Future<AppData?> _readDatabase({required String accountPhone}) async {
    final selectedMember =
        await (_database.select(_database.memberRows)
              ..where((member) => member.accountPhone.equals(accountPhone)))
            .getSingleOrNull();
    if (selectedMember == null) return null;
    final products = await _database.select(_database.productRows).get();
    final banners = await _database.select(_database.bannerRows).get();
    final sections = await _database.select(_database.sectionRows).get();
    final shops = await _database.select(_database.shopRows).get();
    final challengeTemplates = await _database
        .select(_database.challengeRows)
        .get();
    final progressRows = await (_database.select(
      _database.memberChallengeRows,
    )..where((row) => row.accountPhone.equals(accountPhone))).get();
    final progressByChallenge = {
      for (final row in progressRows) row.challengeId: row.progress,
    };

    return AppData(
      member: Member(
        id: selectedMember.id,
        name: selectedMember.name,
        tier: selectedMember.tier,
        points: selectedMember.points,
        pointsToGold: selectedMember.pointsToGold,
        notifications: selectedMember.notifications,
        image: selectedMember.image,
      ),
      products: products.map(_productFromRow).toList(growable: false),
      banners: banners
          .map(
            (row) => PromoBanner(
              title: row.title,
              subtitle: row.subtitle,
              image: row.image,
            ),
          )
          .toList(growable: false),
      sections: sections
          .map(
            (row) => HomeSection(
              id: row.id,
              title: row.title,
              productIds: (jsonDecode(row.productIdsJson) as List)
                  .cast<String>(),
            ),
          )
          .toList(growable: false),
      shops: shops.map((row) => row.name).toList(growable: false),
      challenges: challengeTemplates
          .map((row) {
            final progress = progressByChallenge[row.id];
            if (progress == null) {
              throw StateError(
                'Missing challenge progress for ${row.id} and $accountPhone.',
              );
            }
            return Challenge(
              id: row.id,
              title: row.title,
              progress: progress,
              target: row.target,
              points: row.points,
              kind: row.kind,
            );
          })
          .toList(growable: false),
    );
  }

  Product _productFromRow(ProductRow row) => Product(
    id: row.id,
    code: row.code,
    name: row.name,
    priceMmk: row.priceMmk,
    isNew: row.isNew,
    discountPercent: row.discountPercent,
    image: row.image,
    description: row.description,
  );
}

String _accountDisplayName(String firstName, String lastName) =>
    '$firstName $lastName'.trim();
