import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/rewards_progress.dart';
import '../../../home/domain/models.dart';
import 'points_ring_painter.dart';

class PointsRing extends StatelessWidget {
  const PointsRing({super.key, required this.member, required this.animation});
  final Member member;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final diameter = math.min(
        270.0,
        math.min(constraints.maxWidth, constraints.maxHeight),
      );
      final progress = MemberRewardProgress.fromMember(member);
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final animatedValue = Motion.curve.transform(animation.value);
          final value = (progress.points * animatedValue).round();
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: CustomPaint(
                painter: PointsRingPainter(
                  progress: progress.nextTierFraction * animatedValue,
                ),
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
                          fontSize: 12,
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
                            fontSize: 20,
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
