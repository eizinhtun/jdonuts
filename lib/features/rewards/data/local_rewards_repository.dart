import '../../../core/result/result.dart';
import '../../home/domain/home_repository.dart';
import '../../home/domain/models.dart';
import '../domain/rewards_repository.dart';

class LocalRewardsRepository implements RewardsRepository {
  const LocalRewardsRepository(this._homeRepository);

  final HomeRepository _homeRepository;

  @override
  Future<Result<RewardsSnapshot>> load() async =>
      _snapshot(await _homeRepository.load());

  @override
  Future<Result<RewardsSnapshot>> refresh() async =>
      _snapshot(await _homeRepository.refresh());

  Result<RewardsSnapshot> _snapshot(Result<AppData> result) =>
      result.fold<Result<RewardsSnapshot>>(
        (data) => Success(
          RewardsSnapshot(member: data.member, challenges: data.challenges),
        ),
        (failure) => Error<RewardsSnapshot>(failure),
      );
}
