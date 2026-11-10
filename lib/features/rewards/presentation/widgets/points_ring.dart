import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';
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
        255.0,
        math.min(constraints.maxWidth, constraints.maxHeight),
      );
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final value =
              (member.points * Motion.curve.transform(animation.value)).round();
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
