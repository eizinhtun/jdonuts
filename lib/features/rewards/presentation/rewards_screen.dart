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
import 'widgets/rewards_bottom_nav.dart';

const _rewardOverviewHeight = 355.0;
const _compactRewardOverviewHeight = 390.0;
const _compactRewardWidth = 380.0;
const _largeTextScale = 1.1;
const _rewardsCanvasColor = Color(0xFFF1F3F3);

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
  bool _isRefreshing = false;
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
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final result = await ref.read(rewardsRepositoryProvider).refresh();
      if (!mounted) return;
      result.fold<void>(
        (_) => ref.invalidate(rewardsDataProvider),
        (failure) =>
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(failure.message))),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'rewards refresh',
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
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
                    onPressed: _isRefreshing ? null : _retry,
                    child: _isRefreshing
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: MediaQuery.disableAnimationsOf(context)
                                  ? .65
                                  : null,
                            ),
                          )
                        : Text(context.l10n.retryLabel),
                  ),
                ],
              ),
            ),
            data: (data) => _content(context, data.member, data.challenges),
          ),
    ),
    bottomNavigationBar: const RewardsBottomNav(),
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
    final compactWidth = MediaQuery.sizeOf(context).width < _compactRewardWidth;
    final ringDiameter = compactWidth ? 220.0 : 256.0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 0, 4),
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
                      style: _rewardsTitleStyle(context),
                    ),
                    Align(alignment: Alignment.centerRight, child: badge),
                  ],
                );
              }
              return Transform.translate(
                offset: const Offset(0, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.rewardsTitle,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: _rewardsTitleStyle(context),
                      ),
                    ),
                    badge,
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: _rewardsCanvasColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ColoredBox(
                    color: AppColors.white,
                    child: SizedBox(
                      height: overviewHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Transform.translate(
                              offset: const Offset(0, 9),
                              child: TierLadder(
                                member: member,
                                animation: _entrance,
                              ),
                            ),
                          ),
                          Expanded(
                            child: OverflowBox(
                              alignment: Alignment.center,
                              minWidth: ringDiameter,
                              maxWidth: ringDiameter,
                              minHeight: ringDiameter,
                              maxHeight: ringDiameter,
                              child: Transform.translate(
                                offset: Offset(compactWidth ? 28 : 44, 9),
                                child: PointsRing(
                                  member: member,
                                  animation: _entrance,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          begin: Offset(
                            tab == 0
                                ? -Motion.rewardTabSlideDistance
                                : Motion.rewardTabSlideDistance,
                            0,
                          ),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: challenges.isEmpty
                        ? Padding(
                            key: ValueKey('empty-$tab'),
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
                            child: Center(
                              child: Text(
                                context.l10n.rewardsEmpty,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Padding(
                            key: ValueKey(tab),
                            padding: EdgeInsets.fromLTRB(
                              compactLayout ? 16 : 22,
                              19,
                              compactLayout ? 16 : 0,
                              20,
                            ),
                            child: Column(
                              children: List.generate(challenges.length, (
                                index,
                              ) {
                                final challenge = tab == 0
                                    ? challenges[index]
                                    : _giftChallenge(challenges[index]);
                                return AnimatedBuilder(
                                  animation: _entrance,
                                  builder: (context, child) {
                                    final start =
                                        (index * Motion.rewardChallengeStagger)
                                            .clamp(
                                              0.0,
                                              Motion.rewardChallengeMaxStagger,
                                            )
                                            .toDouble();
                                    final progress = Motion.curve.transform(
                                      (_entrance.value - start)
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                    );
                                    return Opacity(
                                      opacity: progress,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          Motion.rewardChallengeSlideDistance *
                                              (1 - progress),
                                        ),
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
        ),
      ],
    );
  }

  Widget _tabs() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0, .52, .53, 1],
        colors: [
          AppColors.white,
          AppColors.white,
          _rewardsCanvasColor,
          _rewardsCanvasColor,
        ],
      ),
    ),
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final groupWidth = (260 * textScale)
            .clamp(248.0, constraints.maxWidth - 8)
            .toDouble();
        final eatWidth = groupWidth * .69;
        final giftWidth = groupWidth - eatWidth - 8;
        final left = ((constraints.maxWidth - groupWidth) / 2 + 24)
            .clamp(0.0, constraints.maxWidth - groupWidth)
            .toDouble();
        return SizedBox(
          height: 36,
          child: Stack(
            children: [
              AnimatedPositionedDirectional(
                start: left + (tab == 0 ? 0 : eatWidth + 8),
                top: 0,
                bottom: 0,
                width: tab == 0 ? eatWidth : giftWidth,
                duration: Motion.duration(context, Motion.standard),
                curve: Motion.curve,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              PositionedDirectional(
                start: left,
                top: 0,
                bottom: 0,
                width: eatWidth,
                child: RewardTab(
                  label: context.l10n.eatMoreEarnMore,
                  selected: tab == 0,
                  onTap: () => _selectTab(0),
                ),
              ),
              PositionedDirectional(
                start: left + eatWidth + 8,
                top: 0,
                bottom: 0,
                width: giftWidth,
                child: RewardTab(
                  label: context.l10n.giftLabel,
                  selected: tab == 1,
                  onTap: () => _selectTab(1),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  void _selectTab(int nextTab) {
    if (tab == nextTab) return;
    setState(() => tab = nextTab);
  }

  TextStyle? _rewardsTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontFamily: Theme.of(context).platform == TargetPlatform.iOS
            ? 'SF Pro Rounded'
            : null,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -.3,
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
