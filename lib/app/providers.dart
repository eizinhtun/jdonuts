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
import '../features/home/domain/models.dart';

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
final dataRepositoryProvider = Provider<LocalDataRepository>(
  (ref) => DriftDataRepository(ref.watch(appDatabaseProvider)),
);
final appDataProvider = FutureProvider<AppData>(
  (ref) async => (await ref.watch(dataRepositoryProvider).load()).fold(
    (data) => data,
    (failure) => throw ResultException(failure),
  ),
);
final sessionProvider = FutureProvider<bool>(
  (ref) => ref.watch(authRepositoryProvider).hasSession(),
);
final authStateProvider = StateProvider<bool?>((ref) => null);
final authDraftProvider = StateProvider<AuthDraft>((ref) => const AuthDraft());
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
