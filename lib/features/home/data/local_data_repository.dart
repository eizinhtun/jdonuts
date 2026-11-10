import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:jdonuts/core/result/result.dart';

import '../../../core/storage/app_database.dart';
import '../domain/models.dart';

abstract interface class LocalDataRepository {
  Future<Result<AppData>> load();
  Future<Result<AppData>> refresh();
}

class DriftDataRepository implements LocalDataRepository {
  DriftDataRepository(this._database, {AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AppDatabase _database;
  final AssetBundle _bundle;

  @override
  Future<Result<AppData>> load() async {
    try {
      await _seedOnFirstLaunch();
      final data = await _readDatabase();
      return data == null
          ? const Error(StorageFailure('The local catalog is empty.'))
          : Success(data);
    } on Object catch (error) {
      return Error(StorageFailure('Could not read local data: $error'));
    }
  }

  @override
  Future<Result<AppData>> refresh() => load();

  Future<void> _seedOnFirstLaunch() async {
    final existing = await _database
        .select(_database.memberRows)
        .getSingleOrNull();
    if (existing != null) return;

    final json = jsonDecode(
      await _bundle.loadString('assets/data/seed.json'),
    ) as Map<String, dynamic>;
    final seed = AppData.fromJson(json);
    await _database.transaction(() async {
      // Recheck inside the transaction so overlapping first reads cannot
      // duplicate the shops or replace partially loaded data.
      final memberInsideTransaction = await _database
          .select(_database.memberRows)
          .getSingleOrNull();
      if (memberInsideTransaction != null) return;

      await _database.delete(_database.memberRows).go();
      await _database.delete(_database.productRows).go();
      await _database.delete(_database.bannerRows).go();
      await _database.delete(_database.sectionRows).go();
      await _database.delete(_database.shopRows).go();
      await _database.delete(_database.challengeRows).go();

      await _database
          .into(_database.memberRows)
          .insert(
            MemberRowsCompanion.insert(
              id: seed.member.id,
              name: seed.member.name,
              tier: seed.member.tier,
              points: seed.member.points,
              pointsToGold: seed.member.pointsToGold,
              notifications: seed.member.notifications,
            ),
          );
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
    });
  }

  Future<AppData?> _readDatabase() async {
    final memberRecord = await _database
        .select(_database.memberRows)
        .getSingleOrNull();
    if (memberRecord == null) return null;
    final products = await _database.select(_database.productRows).get();
    final banners = await _database.select(_database.bannerRows).get();
    final sections = await _database.select(_database.sectionRows).get();
    final shops = await _database.select(_database.shopRows).get();
    final challenges = await _database.select(_database.challengeRows).get();

    return AppData(
      member: Member(
        id: memberRecord.id,
        name: memberRecord.name,
        tier: memberRecord.tier,
        points: memberRecord.points,
        pointsToGold: memberRecord.pointsToGold,
        notifications: memberRecord.notifications,
      ),
      products: products
          .map(
            (row) => Product(
              id: row.id,
              code: row.code,
              name: row.name,
              priceMmk: row.priceMmk,
              isNew: row.isNew,
              discountPercent: row.discountPercent,
              image: row.image,
              description: row.description,
            ),
          )
          .toList(growable: false),
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
      challenges: challenges
          .map(
            (row) => Challenge(
              id: row.id,
              title: row.title,
              progress: row.progress,
              target: row.target,
              points: row.points,
              kind: row.kind,
            ),
          )
          .toList(growable: false),
    );
  }
}
