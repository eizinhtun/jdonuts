import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/rewards_progress.dart';
import '../../../home/domain/models.dart';

class TierLadder extends StatelessWidget {
  const TierLadder({super.key, required this.member, required this.animation});
  final Member member;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final progress = MemberRewardProgress.fromMember(member);
    final narrow =
        MediaQuery.sizeOf(context).width < 380 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.1;
    return Padding(
      padding: EdgeInsets.fromLTRB(narrow ? 24 : 35, 20, 0, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 145 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.1;
          final iconLabelGap = compact ? 8.0 : 14.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stagger(
                0,
                _tier(
                  'S',
                  context.l10n.silverTier,
                  _silverSubtitle(context, progress),
                  AppColors.silver,
                  stars: 1,
                  isCurrent: progress.isCurrentTier(MembershipTier.silver),
                  context: context,
                  gap: iconLabelGap,
                ),
              ),
              _animatedLine(
                _silverToGoldProgress(progress),
                color: const Color(0xFF74777A),
                height: compact ? 55 : 69,
              ),
              _stagger(
                .16,
                _tier(
                  'G',
                  context.l10n.goldTier,
                  _goldSubtitle(context, progress),
                  AppColors.gold,
                  stars: 2,
                  isCurrent: progress.isCurrentTier(MembershipTier.gold),
                  context: context,
                  gap: iconLabelGap,
                ),
              ),
              _animatedLine(
                progress.isCurrentTier(MembershipTier.platinum) ? 1 : 0,
                height: compact ? 35 : 49,
              ),
              _stagger(
                .32,
                _tier(
                  'P',
                  context.l10n.platinumTier,
                  _platinumSubtitle(context, progress),
                  AppColors.platinum,
                  stars: 3,
                  isCurrent: progress.isCurrentTier(MembershipTier.platinum),
                  context: context,
                  gap: iconLabelGap,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _goldSubtitle(BuildContext context, MemberRewardProgress progress) =>
      switch (progress.currentTier) {
        MembershipTier.silver => context.l10n.pointsRemaining(
          progress.pointsToNextTier,
        ),
        MembershipTier.gold => context.l10n.currentTier,
        MembershipTier.platinum => context.l10n.tierCompleted,
        MembershipTier.unknown => context.l10n.futureTier,
      };

  String _silverSubtitle(BuildContext context, MemberRewardProgress progress) =>
      switch (progress.currentTier) {
        MembershipTier.silver => context.l10n.currentTier,
        MembershipTier.gold ||
        MembershipTier.platinum => context.l10n.tierCompleted,
        MembershipTier.unknown => context.l10n.futureTier,
      };

  String _platinumSubtitle(
    BuildContext context,
    MemberRewardProgress progress,
  ) => progress.isCurrentTier(MembershipTier.platinum)
      ? context.l10n.currentTier
      : context.l10n.futureTier;

  double _silverToGoldProgress(MemberRewardProgress progress) =>
      switch (progress.currentTier) {
        MembershipTier.silver => progress.nextTierFraction,
        MembershipTier.gold || MembershipTier.platinum => 1,
        MembershipTier.unknown => 0,
      };

  Widget _animatedLine(
    double targetProgress, {
    Color color = AppColors.pink,
    double height = 52,
  }) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => _line(
      targetProgress * Motion.curve.transform(animation.value),
      color: color,
      height: height,
    ),
  );

  Widget _stagger(double start, Widget child) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final progress = Motion.curve.transform(
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

  Widget _line(
    double progress, {
    Color color = AppColors.pink,
    double height = 52,
  }) => Padding(
    padding: const EdgeInsets.only(left: 17),
    child: SizedBox(
      height: height,
      child: SizedBox(
        width: 2,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.tierConnector),
            ),
            FractionallySizedBox(
              widthFactor: 1,
              heightFactor: progress.clamp(0.0, 1.0),
              child: ColoredBox(color: color),
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
    required int stars,
    required bool isCurrent,
    required BuildContext context,
    required double gap,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    child: Row(
      children: [
        SizedBox(
          width: 36,
          height: 40,
          child: CustomPaint(
            painter: _TierMarkPainter(
              fill: color.withValues(alpha: .35),
              stroke: color,
              strokeWidth: 2,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      stars,
                      (_) => Icon(
                        Icons.star,
                        size: 6,
                        color: AppColors.ink.withValues(alpha: .42),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    mark,
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: .65),
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                  color: AppColors.ink,
                  fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                      ? 'SF Pro Rounded'
                      : null,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, height: 1.2),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TierMarkPainter extends CustomPainter {
  const _TierMarkPainter({
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
  });

  final Color fill;
  final Color stroke;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final path = Path()
      ..moveTo(size.width * .18, inset)
      ..quadraticBezierTo(size.width / 2, -inset, size.width * .82, inset)
      ..lineTo(size.width - inset, size.height * .58)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + inset,
        inset,
        size.height * .58,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _TierMarkPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.stroke != stroke ||
      oldDelegate.strokeWidth != strokeWidth;
}
