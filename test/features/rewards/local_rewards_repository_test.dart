import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/home/domain/home_repository.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/rewards/data/local_rewards_repository.dart';
import 'package:jdonuts/features/rewards/domain/rewards_repository.dart';

void main() {
  test('rewards reads the same stored member and challenge records', () async {
    final homeRepository = _FakeHomeRepository(_appData);
    final repository = LocalRewardsRepository(homeRepository);

    final result = await repository.load();

    expect(result, isA<Success<RewardsSnapshot>>());
    final snapshot = (result as Success<RewardsSnapshot>).value;
    expect(snapshot.member.points, 680000);
    expect(snapshot.member.pointsToGold, 500);
    expect(snapshot.challenges.single.id, 'coffee');
    expect(homeRepository.loads, 1);
  });

  test('refresh delegates to the local source of truth', () async {
    final homeRepository = _FakeHomeRepository(_appData);
    final repository = LocalRewardsRepository(homeRepository);

    expect(await repository.refresh(), isA<Success<RewardsSnapshot>>());
    expect(homeRepository.refreshes, 1);
  });
}

class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository(this.data);
  final AppData data;
  int loads = 0;
  int refreshes = 0;

  @override
  Future<Result<AppData>> load() async {
    loads++;
    return Success(data);
  }

  @override
  Future<Result<AppData>> loadForAccount(String accountPhone) async {
    loads++;
    return Success(data);
  }

  @override
  Future<Result<AppData>> refresh() async {
    refreshes++;
    return Success(data);
  }

  @override
  Future<Result<AppData>> refreshForAccount(String accountPhone) async {
    refreshes++;
    return Success(data);
  }

  @override
  Future<Result<List<Product>>> loadSectionProducts(String sectionId) async =>
      const Success([]);
}

final _appData = AppData(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  products: const [],
  sections: const [],
  banners: const [],
  shops: const [],
  challenges: const [
    Challenge(
      id: 'coffee',
      title: 'Enjoy coffee moments',
      progress: 9,
      target: 12,
      points: 100,
      kind: 'coffee',
    ),
  ],
);
