import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../app/providers.dart';

import 'widgets/challenge_card.dart';
import 'widgets/points_ring.dart';
import 'widgets/reward_tab.dart';
import 'widgets/tier_ladder.dart';
import 'widgets/rewards_badge.dart';
import '../../home/domain/models.dart';
import '../../home/presentation/widgets/app_bottom_nav.dart';

const _rewardOverviewHeight = 300.0;
const _compactRewardOverviewHeight = 370.0;
const _compactRewardWidth = 380.0;
const _largeTextScale = 1.1;

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
    final result = await ref.read(rewardsRepositoryProvider).refresh();
    if (!mounted) return;
    result.fold<void>(
      (_) => ref.invalidate(rewardsDataProvider),
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
          .watch(rewardsDataProvider)
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
    final compactLayout =
        MediaQuery.sizeOf(context).width < _compactRewardWidth ||
        MediaQuery.textScalerOf(context).scale(1) > _largeTextScale;
    final overviewHeight = compactLayout
        ? _compactRewardOverviewHeight
        : _rewardOverviewHeight;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final badge = RewardsBadge(animation: _entrance);
              final largeText =
                  MediaQuery.textScalerOf(context).scale(1) > _largeTextScale;
              if (constraints.maxWidth < 340 || largeText) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.rewardsTitle,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20),
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
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20),
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
                  height: overviewHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: TierLadder(member: member, animation: _entrance),
                      ),
                      Expanded(
                        child: PointsRing(member: member, animation: _entrance),
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
                            final progress = Motion.curve.transform(
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
                          child: ChallengeCard(
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
                  RewardTab(
                    label: context.l10n.eatMoreEarnMore,
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  const SizedBox(width: 8),
                  RewardTab(
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
