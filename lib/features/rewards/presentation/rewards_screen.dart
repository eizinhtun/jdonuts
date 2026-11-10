import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../app/providers.dart';
import 'widgets/points_ring_painter.dart';
import '../../home/domain/models.dart';
import '../../home/presentation/home_screen.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  bool _entranceStarted = false;
  bool? _reduceMotion;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: Motion.entrance);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _entrance.stop();
      _entrance.value = 1;
      _entranceStarted = true;
    } else if (_entranceStarted && _entrance.value < 1) {
      _entrance.forward();
    }
  }

  void _startEntrance() {
    if (_entranceStarted) return;
    _entranceStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _entrance.forward();
    });
  }

  Future<void> _retry() async {
    final result = await ref.read(dataRepositoryProvider).refresh();
    if (!mounted) return;
    result.fold<void>(
      (_) => ref.invalidate(appDataProvider),
      (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

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
            loading: () => Center(
              child: CircularProgressIndicator(
                value: MediaQuery.disableAnimationsOf(context) ? .65 : null,
              ),
            ),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.rewardsUnavailable),
                  TextButton(
                    onPressed: _retry,
                    child: Text(context.l10n.retryLabel),
                  ),
                ],
              ),
            ),
            data: (data) => _content(context, data.member, data.challenges),
          ),
    ),
    bottomNavigationBar: const AppBottomNav(selected: 2),
  );
  Widget _content(
    BuildContext context,
    Member member,
    List<Challenge> challenges,
  ) {
    _startEntrance();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final badge = _rewardsBadge(context);
              if (constraints.maxWidth < 380) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.rewardsTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 23),
                    ),
                    Align(alignment: Alignment.centerRight, child: badge),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.rewardsTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  badge,
                ],
              );
            },
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
                      Expanded(
                        child: _TierLadder(
                          member: member,
                          animation: _entrance,
                        ),
                      ),
                      Expanded(
                        child: _PointsRing(
                          member: member,
                          animation: _entrance,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _tabs()),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: Motion.duration(context, Motion.standard),
                  switchInCurve: Motion.curve,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(tab == 0 ? -.06 : .06, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    key: ValueKey(tab),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      children: List.generate(challenges.length, (index) {
                        final challenge = tab == 0
                            ? challenges[index]
                            : _giftChallenge(challenges[index]);
                        return AnimatedBuilder(
                          animation: _entrance,
                          builder: (context, child) {
                            final start = (index * .13).clamp(0.0, .65);
                            final progress = Curves.easeOutCubic.transform(
                              (_entrance.value - start).clamp(0.0, 1.0),
                            );
                            return Opacity(
                              opacity: progress,
                              child: Transform.translate(
                                offset: Offset(0, 35 * (1 - progress)),
                                child: child,
                              ),
                            );
                          },
                          child: _ChallengeCard(
                            key: ValueKey(challenge.id),
                            challenge: challenge,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rewardsBadge(BuildContext context) => ScaleTransition(
    scale: CurvedAnimation(
      parent: _entrance,
      curve: const Interval(.1, .6, curve: Curves.elasticOut),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.rewardsBadge,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
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
  );

  Widget _tabs() => Container(
    color: AppColors.canvas,
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = (constraints.maxWidth - 8) / 2;
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              AnimatedPositionedDirectional(
                start: tab == 0 ? 0 : tabWidth + 8,
                top: 0,
                bottom: 0,
                width: tabWidth,
                duration: Motion.duration(context, Motion.standard),
                curve: Motion.curve,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              Row(
                children: [
                  _RewardTab(
                    label: context.l10n.eatMoreEarnMore,
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  const SizedBox(width: 8),
                  _RewardTab(
                    label: context.l10n.giftLabel,
                    selected: tab == 1,
                    onTap: () => setState(() => tab = 1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
  Challenge _giftChallenge(Challenge source) => Challenge(
    id: 'gift-${source.id}',
    title: context.l10n.giftChallenge,
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
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: Motion.duration(context, Motion.quick),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}

class _TierLadder extends StatelessWidget {
  const _TierLadder({required this.member, required this.animation});
  final Member member;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 0, 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stagger(
          0,
          _tier(
            'S',
            context.l10n.silverTier,
            context.l10n.currentTier,
            const Color(0xFFBEC4C7),
            current: true,
            progress: null,
            context: context,
          ),
        ),
        _line(_goldProgress),
        _stagger(
          .16,
          _tier(
            'G',
            context.l10n.goldTier,
            context.l10n.pointsRemaining(member.pointsToGold),
            const Color(0xFFF2D565),
            current: false,
            progress: _goldProgress,
            context: context,
          ),
        ),
        _line(.08),
        _stagger(
          .32,
          _tier(
            'P',
            context.l10n.platinumTier,
            context.l10n.futureTier,
            const Color(0xFF79D7E8),
            current: false,
            progress: null,
            context: context,
          ),
        ),
      ],
    ),
  );

  double get _goldProgress {
    final targetPoints = member.points + member.pointsToGold;
    if (targetPoints <= 0) return 0;
    return (member.points / targetPoints).clamp(0.0, 1.0).toDouble();
  }

  Widget _stagger(double start, Widget child) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final progress = Curves.easeOutCubic.transform(
        ((animation.value - start) / (1 - start)).clamp(0.0, 1.0),
      );
      return Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(-18 * (1 - progress), 0),
          child: child,
        ),
      );
    },
  );

  Widget _line(double progress) => Padding(
    padding: const EdgeInsets.only(left: 19),
    child: SizedBox(
      height: 32,
      child: SizedBox(
        width: 3,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const ColoredBox(color: Color(0xFFE2E4E5)),
            FractionallySizedBox(
              heightFactor: progress.clamp(0.0, 1.0),
              child: const ColoredBox(color: AppColors.pink),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tier(
    String mark,
    String title,
    String subtitle,
    Color color, {
    required bool current,
    required double? progress,
    required BuildContext context,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    decoration: current
        ? BoxDecoration(
            color: AppColors.palePink,
            border: Border.all(color: AppColors.pink.withValues(alpha: .45)),
            borderRadius: BorderRadius.circular(16),
          )
        : null,
    child: Row(
      children: [
        Container(
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .35),
            border: Border.all(
              color: current ? AppColors.pink : color,
              width: current ? 2.5 : 2,
            ),
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
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: current ? AppColors.pink : AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, height: 1.25),
              ),
              if (progress != null) ...[
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.canvas,
                    color: AppColors.pink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _PointsRing extends StatelessWidget {
  const _PointsRing({required this.member, required this.animation});
  final Member member;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final diameter = math.min(
        255.0,
        math.min(constraints.maxWidth, constraints.maxHeight),
      );
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final value =
              (member.points * Curves.easeOutCubic.transform(animation.value))
                  .round();
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: CustomPaint(
                painter: PointsRingPainter(progress: animation.value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.totalPoints,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.pink,
                          fontWeight: FontWeight.w700,
                          fontSize: diameter < 205 ? 12 : 14,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value.toString().replaceAllMapped(
                            RegExp(r'(?<=\d)(?=(\d{3})+$)'),
                            (_) => ',',
                          ),
                          style: TextStyle(
                            color: AppColors.pink,
                            fontSize: diameter < 205 ? 21 : 27,
                            fontWeight: FontWeight.w900,
                          ),
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
    },
  );
}

class _ChallengeCard extends StatefulWidget {
  const _ChallengeCard({super.key, required this.challenge});
  final Challenge challenge;

  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attention;
  bool? _reduceMotion;
  bool? _wasComplete;
  bool _claimed = false;

  bool get _complete =>
      widget.challenge.target > 0 &&
      widget.challenge.progress >= widget.challenge.target;

  @override
  void initState() {
    super.initState();
    _attention = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAttention();
  }

  @override
  void didUpdateWidget(covariant _ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.progress != widget.challenge.progress ||
        oldWidget.challenge.target != widget.challenge.target) {
      _syncAttention();
    }
  }

  void _syncAttention() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final complete = _complete && !_claimed;
    if (_reduceMotion == reduceMotion && _wasComplete == complete) return;
    _reduceMotion = reduceMotion;
    _wasComplete = complete;
    if (complete && !reduceMotion) {
      _attention.repeat(reverse: true);
    } else {
      _attention.stop();
      _attention.value = 0;
    }
  }

  @override
  void dispose() {
    _attention.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final complete = _complete;
    final fraction = challenge.target <= 0
        ? 0.0
        : (challenge.progress / challenge.target).clamp(0.0, 1.0).toDouble();
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
                fraction: fraction,
                donut: challenge.kind == 'donut',
              ),
              child: Center(
                child: Icon(
                  challenge.kind == 'donut' ? Icons.donut_large : Icons.coffee,
                  size: 53,
                  color: challenge.kind == 'donut'
                      ? const Color(0xFFE86C9A)
                      : const Color(0xFFAA694C),
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
                  context.l10n.challengeCount(
                    challenge.progress,
                    challenge.target,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 1, end: 1.035).animate(
                        CurvedAnimation(
                          parent: _attention,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: FilledButton(
                        onPressed: complete && !_claimed
                            ? () {
                                setState(() => _claimed = true);
                                _syncAttention();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.pointsClaimed(
                                        challenge.points,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          disabledBackgroundColor: const Color(0xFFE0E3E4),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                        ),
                        child: Text(
                          _claimed
                              ? context.l10n.earnedLabel
                              : context.l10n.earnLabel,
                        ),
                      ),
                    ),
                    Text(context.l10n.earnPoints(challenge.points)),
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
    final progress = fraction.clamp(0.0, 1.0).toDouble();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .38;
    if (donut) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = const Color(0xFFFFE1EA),
      );
      for (var i = 0; i < 4; i++) {
        if (progress * 4 > i) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            -math.pi / 2 + i * math.pi / 2,
            math.min(math.pi / 2, progress * math.pi * 2 - i * math.pi / 2),
            true,
            Paint()..color = const Color(0xFFEC75A0),
          );
        }
      }
      canvas.drawCircle(center, radius * .45, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.canvas);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
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
