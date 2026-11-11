import '../../home/domain/models.dart';

enum MembershipTier { silver, gold, platinum, unknown }

class MemberRewardProgress {
  const MemberRewardProgress({
    required this.points,
    required this.pointsToNextTier,
    required this.nextTierFraction,
    required this.currentTier,
  });

  final int points;
  final int pointsToNextTier;
  final double nextTierFraction;
  final MembershipTier currentTier;

  factory MemberRewardProgress.fromMember(Member member) {
    final points = member.points.clamp(0, 0x7fffffff).toInt();
    final pointsToNextTier = member.pointsToGold.clamp(0, 0x7fffffff).toInt();
    final target = points + pointsToNextTier;
    final currentTier = switch (member.tier.trim().toLowerCase()) {
      'silver' => MembershipTier.silver,
      'gold' => MembershipTier.gold,
      'platinum' => MembershipTier.platinum,
      _ => MembershipTier.unknown,
    };
    final fraction = currentTier != MembershipTier.silver || target == 0
        ? 0.0
        : points / target;
    return MemberRewardProgress(
      points: points,
      pointsToNextTier: pointsToNextTier,
      nextTierFraction: fraction.clamp(0.0, 1.0).toDouble(),
      currentTier: currentTier,
    );
  }

  bool isCurrentTier(MembershipTier tier) => currentTier == tier;
}

class ChallengeProgress {
  const ChallengeProgress({
    required this.completedCount,
    required this.targetCount,
    required this.points,
  });

  final int completedCount;
  final int targetCount;
  final int points;

  double get fraction => targetCount == 0
      ? 0
      : (completedCount / targetCount).clamp(0.0, 1.0).toDouble();

  bool get isComplete => targetCount > 0 && completedCount >= targetCount;

  factory ChallengeProgress.fromChallenge(Challenge challenge) {
    final target = challenge.target.clamp(0, 0x7fffffff).toInt();
    return ChallengeProgress(
      targetCount: target,
      completedCount: target == 0
          ? 0
          : challenge.progress.clamp(0, target).toInt(),
      points: challenge.points.clamp(0, 0x7fffffff).toInt(),
    );
  }
}
