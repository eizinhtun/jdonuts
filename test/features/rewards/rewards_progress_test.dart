import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/rewards/domain/rewards_progress.dart';

void main() {
  group('MemberRewardProgress', () {
    test('maps the shared 1,000,000 points and Silver tier record', () {
      final progress = MemberRewardProgress.fromMember(_member());

      expect(progress.points, 1000000);
      expect(progress.currentTier, MembershipTier.silver);
      expect(progress.pointsToNextTier, 500);
      expect(progress.nextTierFraction, closeTo(1000000 / 1000500, 0.000001));
      expect(progress.isCurrentTier(MembershipTier.silver), isTrue);
    });

    test('recognizes other persisted tiers without changing point values', () {
      final progress = MemberRewardProgress.fromMember(_member(tier: 'Gold'));

      expect(progress.currentTier, MembershipTier.gold);
      expect(progress.isCurrentTier(MembershipTier.gold), isTrue);
      expect(progress.nextTierFraction, 0);
    });

    test('clamps invalid negative values and handles a zero target', () {
      final progress = MemberRewardProgress.fromMember(
        _member(points: -10, pointsToGold: -5),
      );

      expect(progress.points, 0);
      expect(progress.pointsToNextTier, 0);
      expect(progress.nextTierFraction, 0);
      expect(progress.nextTierFraction.isFinite, isTrue);
    });
  });

  group('ChallengeProgress', () {
    test('calculates quarters and completion safely', () {
      final quarter = ChallengeProgress.fromChallenge(
        _challenge(progress: 1, target: 4),
      );
      final completed = ChallengeProgress.fromChallenge(
        _challenge(progress: 4, target: 4),
      );
      final coffee = ChallengeProgress.fromChallenge(
        _challenge(progress: 9, target: 12),
      );

      expect(quarter.fraction, .25);
      expect(quarter.isComplete, isFalse);
      expect(completed.fraction, 1);
      expect(completed.isComplete, isTrue);
      expect(coffee.fraction, .75);
    });

    test('clamps malformed progress and disables zero-target challenges', () {
      final tooMuch = ChallengeProgress.fromChallenge(
        _challenge(progress: 12, target: 4, points: -50),
      );
      final invalid = ChallengeProgress.fromChallenge(
        _challenge(progress: -3, target: -1),
      );

      expect(tooMuch.completedCount, 4);
      expect(tooMuch.fraction, 1);
      expect(tooMuch.points, 0);
      expect(tooMuch.isComplete, isTrue);
      expect(invalid.completedCount, 0);
      expect(invalid.targetCount, 0);
      expect(invalid.fraction, 0);
      expect(invalid.fraction.isFinite, isTrue);
      expect(invalid.isComplete, isFalse);
    });
  });
}

Member _member({
  int points = 1000000,
  int pointsToGold = 500,
  String tier = 'Silver',
}) => Member(
  id: 'member-1',
  name: 'Hania',
  tier: tier,
  points: points,
  pointsToGold: pointsToGold,
  notifications: 2,
);

Challenge _challenge({int progress = 0, int target = 4, int points = 100}) =>
    Challenge(
      id: 'challenge',
      title: 'Eat donuts',
      progress: progress,
      target: target,
      points: points,
      kind: 'donut',
    );
