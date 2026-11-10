import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../main.dart';
import '../../home/domain/models.dart';
import '../../home/presentation/home_screen.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: Motion.entrance,
  )..forward();
  int tab = 0;
  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: ref
          .watch(appDataProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text('Rewards are unavailable')),
            data: (data) => _content(context, data.member, data.challenges),
          ),
    ),
    bottomNavigationBar: const AppBottomNav(selected: 2),
  );
  Widget _content(
    BuildContext context,
    Member member,
    List<Challenge> challenges,
  ) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'J’ Donuts Rewards',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _entrance,
                curve: const Interval(.1, .6, curve: Curves.elasticOut),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(28),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Rewards',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.white,
                      child: Text(
                        '3',
                        style: TextStyle(color: AppColors.ink, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 390,
                child: Row(
                  children: [
                    Expanded(child: _TierLadder(member: member)),
                    Expanded(
                      child: _PointsRing(member: member, animation: _entrance),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _tabs()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final challenge = tab == 0
                      ? challenges[index]
                      : _giftChallenge(challenges[index]);
                  return AnimatedBuilder(
                    animation: _entrance,
                    builder: (context, child) {
                      final start = (index * .13).clamp(0.0, .65);
                      final p = Curves.easeOutCubic.transform(
                        (_entrance.value - start).clamp(0.0, 1.0),
                      );
                      return Opacity(
                        opacity: p,
                        child: Transform.translate(
                          offset: Offset(0, 35 * (1 - p)),
                          child: child,
                        ),
                      );
                    },
                    child: _ChallengeCard(challenge: challenge),
                  );
                }, childCount: challenges.length),
              ),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _tabs() => Container(
    color: AppColors.canvas,
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
    child: Row(
      children: [
        _RewardTab(
          label: 'Eat more earn more',
          selected: tab == 0,
          onTap: () => setState(() => tab = 0),
        ),
        _RewardTab(
          label: 'Gift',
          selected: tab == 1,
          onTap: () => setState(() => tab = 1),
        ),
      ],
    ),
  );
  Challenge _giftChallenge(Challenge source) => Challenge(
    id: 'gift-${source.id}',
    title: 'Gift a treat to a friend',
    progress: source.progress,
    target: source.target,
    points: source.points,
    kind: source.kind,
  );
}

class _RewardTab extends StatelessWidget {
  const _RewardTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.duration(context, Motion.standard),
        margin: const EdgeInsets.only(right: 8, bottom: 0),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.member});
  final Member member;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 0, 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tier('S', 'Silver', 'You’re here now', const Color(0xFFBEC4C7), true),
        _line(.72),
        _tier(
          'G',
          'Gold',
          '${member.pointsToGold} pts Remaining\nto become Gold',
          const Color(0xFFF2D565),
          false,
        ),
        _line(.08),
        _tier(
          'P',
          'Platinum',
          'You’ll be here soon',
          const Color(0xFF79D7E8),
          false,
        ),
      ],
    ),
  );
  Widget _line(double progress) => Padding(
    padding: const EdgeInsets.only(left: 19),
    child: SizedBox(
      height: 32,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 3,
          height: 32 * progress.clamp(.08, 1),
          color: const Color(0xFF8D9295),
        ),
      ),
    ),
  );
  Widget _tier(
    String mark,
    String title,
    String subtitle,
    Color color,
    bool current,
  ) => Row(
    children: [
      Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .35),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            mark,
            style: TextStyle(
              color: AppColors.ink.withValues(alpha: .65),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(subtitle, style: const TextStyle(fontSize: 11, height: 1.4)),
          ],
        ),
      ),
    ],
  );
}

class _PointsRing extends StatelessWidget {
  const _PointsRing({required this.member, required this.animation});
  final Member member;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final value =
          (member.points * Curves.easeOutCubic.transform(animation.value))
              .round();
      return Center(
        child: SizedBox(
          width: 255,
          height: 255,
          child: CustomPaint(
            painter: PointsRingPainter(
              progress: animation.value,
              color: AppColors.pink,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total points',
                    style: TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    value.toString().replaceAllMapped(
                      RegExp(r'(?<=\d)(?=(\d{3})+$)'),
                      (_) => ',',
                    ),
                    style: const TextStyle(
                      color: AppColors.pink,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});
  final Challenge challenge;
  @override
  Widget build(BuildContext context) {
    final complete = challenge.progress >= challenge.target;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 105,
            child: CustomPaint(
              painter: _ChallengePainter(
                fraction: challenge.progress / challenge.target,
                donut: challenge.kind == 'donut',
              ),
              child: const Center(
                child: Icon(
                  Icons.donut_large,
                  size: 53,
                  color: Color(0xFFE86C9A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${challenge.progress}/${challenge.target}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AnimatedScale(
                      scale: complete ? 1.04 : 1,
                      duration: Motion.duration(context, Motion.standard),
                      child: FilledButton(
                        onPressed: complete ? () {} : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          disabledBackgroundColor: const Color(0xFFE0E3E4),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                        ),
                        child: const Text('EARN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${challenge.points} pts'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePainter extends CustomPainter {
  const _ChallengePainter({required this.fraction, required this.donut});
  final double fraction;
  final bool donut;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .38;
    if (donut) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = const Color(0xFFFFE1EA),
      );
      for (var i = 0; i < 4; i++) {
        if (fraction * 4 > i)
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            -math.pi / 2 + i * math.pi / 2,
            math.min(math.pi / 2, fraction * math.pi * 2 - i * math.pi / 2),
            true,
            Paint()..color = const Color(0xFFEC75A0),
          );
      }
      canvas.drawCircle(center, radius * .45, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.canvas);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
        Paint()
          ..color = const Color(0xFFAA694C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChallengePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.donut != donut;
}
