import '../../../core/result/result.dart';
import '../../home/domain/models.dart';

class RewardsSnapshot {
  RewardsSnapshot({required this.member, required List<Challenge> challenges})
    : challenges = List.unmodifiable(challenges);

  final Member member;
  final List<Challenge> challenges;
}

abstract interface class RewardsRepository {
  Future<Result<RewardsSnapshot>> load();
  Future<Result<RewardsSnapshot>> refresh();
}
