import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class PointsRingPainter extends CustomPainter {
  const PointsRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 15;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFEEF0F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26,
    );
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      Paint()
        ..color = AppColors.pink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant PointsRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
