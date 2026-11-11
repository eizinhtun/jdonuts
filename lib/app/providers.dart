import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/result/result.dart';
import '../core/network/network_reachability.dart';
import '../core/storage/app_database.dart';
import '../features/auth/data/auth_account_store.dart';
import '../features/auth/data/local_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_draft.dart';
import '../features/home/data/local_data_repository.dart';
import '../features/home/domain/home_repository.dart';
import '../features/home/domain/models.dart';
import '../features/product/data/local_product_repository.dart';
import '../features/product/domain/product_repository.dart';
import '../features/rewards/data/local_rewards_repository.dart';
import '../features/rewards/domain/rewards_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
final connectivityProvider = StreamProvider<bool>((ref) {
  final reachability = NetworkReachability();
  ref.onDispose(reachability.dispose);
  return reachability.watch();
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LocalAuthRepository(
    accountStore: DriftAuthAccountStore(ref.watch(appDatabaseProvider)),
  ),
);
final dataRepositoryProvider = Provider<HomeRepository>(
  (ref) => DriftDataRepository(ref.watch(appDatabaseProvider)),
);
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => LocalProductRepository(ref.watch(dataRepositoryProvider)),
);
final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => LocalRewardsRepository(ref.watch(dataRepositoryProvider)),
);
final appDataProvider = FutureProvider<AppData>(
  (ref) async => (await ref.watch(dataRepositoryProvider).load()).fold(
    (data) => data,
    (failure) => throw ResultException(failure),
  ),
  retry: (_, _) => null,
);
final sectionProductsProvider = FutureProvider.family<List<Product>, String>(
  (ref, sectionId) async =>
      (await ref.watch(dataRepositoryProvider).loadSectionProducts(sectionId))
          .fold(
            (products) => products,
            (failure) => throw ResultException(failure),
          ),
  retry: (_, _) => null,
);
final productProvider = FutureProvider.family<Product?, String>(
  (ref, productId) async =>
      (await ref.watch(productRepositoryProvider).findById(productId)).fold(
        (product) => product,
        (failure) => throw ResultException(failure),
      ),
  retry: (_, _) => null,
);
final rewardsDataProvider = FutureProvider<RewardsSnapshot>(
  (ref) async => (await ref.watch(rewardsRepositoryProvider).load()).fold(
    (snapshot) => snapshot,
    (failure) => throw ResultException(failure),
  ),
  retry: (_, _) => null,
);
final sessionProvider = FutureProvider<Result<bool>>(
  (ref) => ref.watch(authRepositoryProvider).hasSession(),
);
final authStateProvider = StateProvider<bool?>((ref) => null);
final authDraftProvider = StateProvider<AuthDraft>((ref) => const AuthDraft());
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
