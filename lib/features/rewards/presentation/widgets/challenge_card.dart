import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';
import 'package:jdonuts/core/theme/tokens.dart';

import '../../../../core/motion/motion.dart';
import '../../domain/rewards_progress.dart';
import '../../../home/domain/models.dart';
import 'challenge_artwork.dart';

class ChallengeCard extends StatefulWidget {
  const ChallengeCard({super.key, required this.challenge});

  final Challenge challenge;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attention;
  late final Animation<double> _attentionScale;
  bool? _reduceMotion;
  bool? _wasComplete;

  bool get _complete =>
      ChallengeProgress.fromChallenge(widget.challenge).isComplete;

  @override
  void initState() {
    super.initState();
    _attention = AnimationController(
      vsync: this,
      duration: Motion.rewardAttention,
    );
    _attentionScale =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 1, end: Motion.rewardAttentionPeakScale),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Motion.rewardAttentionPeakScale, end: 1),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _attention,
            curve: Motion.rewardAttentionCurve,
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAttention();
  }

  @override
  void didUpdateWidget(covariant ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.progress != widget.challenge.progress ||
        oldWidget.challenge.target != widget.challenge.target) {
      _syncAttention();
    }
  }

  void _syncAttention() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final complete = _complete;
    if (_reduceMotion == reduceMotion && _wasComplete == complete) return;
    _reduceMotion = reduceMotion;
    _wasComplete = complete;
    if (complete && !reduceMotion) {
      _attention.forward(from: 0);
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
    final compactLayout =
        MediaQuery.sizeOf(context).width < 380 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.1;
    final artworkWidth = compactLayout ? 96.0 : 132.0;
    final complete = _complete;
    final progress = ChallengeProgress.fromChallenge(challenge);
    return Container(
      margin: EdgeInsets.only(bottom: compactLayout ? 14 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: compactLayout ? AppSpace.md : 31,
        vertical: compactLayout ? AppSpace.mdPlus : 30,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: artworkWidth,
            height: 116,
            child: ChallengeArtwork(
              kind: challenge.kind,
              progress: progress.fraction,
            ),
          ),
          SizedBox(width: compactLayout ? AppSpace.smPlus : 27),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.challengeHeading.copyWith(
                    fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                        ? 'SF Pro Rounded'
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpace.compact),
                Text(
                  context.l10n.challengeCount(
                    progress.completedCount,
                    progress.targetCount,
                  ),
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpace.cardGap),
                Wrap(
                  spacing: AppSpace.smPlus,
                  runSpacing: AppSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _attentionScale,
                      child: FilledButton(
                        onPressed: complete ? _showEarnFeedback : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          backgroundColor: AppColors.cyan,
                          disabledBackgroundColor: AppColors.challengeDisabled,
                          foregroundColor: AppColors.white,
                          disabledForegroundColor: AppColors.white,
                        ),
                        child: Text(
                          context.l10n.earnLabel,
                          style: AppTypography.earnButtonLabel,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.earnPoints(progress.points),
                      style: AppTypography.body,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEarnFeedback() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
  }
}
