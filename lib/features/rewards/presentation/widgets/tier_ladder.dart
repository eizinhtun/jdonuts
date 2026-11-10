import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';
import '../../../home/domain/models.dart';

class TierLadder extends StatelessWidget {
  const TierLadder({super.key, required this.member, required this.animation});
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
            AppColors.silver,
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
            AppColors.gold,
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
            AppColors.platinum,
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

  Widget _line(double progress) => Padding(
    padding: const EdgeInsets.only(left: 17),
    child: SizedBox(
      height: 22,
      child: SizedBox(
        width: 2,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const ColoredBox(color: AppColors.tierConnector),
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
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    decoration: current
        ? BoxDecoration(
            color: AppColors.palePink,
            border: Border.all(color: AppColors.pink.withValues(alpha: .45)),
            borderRadius: BorderRadius.circular(16),
          )
        : null,
    child: Row(
      children: [
        SizedBox(
          width: 36,
          height: 40,
          child: CustomPaint(
            painter: _TierMarkPainter(
              fill: color.withValues(alpha: .35),
              stroke: current ? AppColors.pink : color,
              strokeWidth: current ? 2.5 : 2,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  mark,
                  style: TextStyle(
                    color: AppColors.ink.withValues(alpha: .65),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: current ? AppColors.pink : AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, height: 1.2),
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
