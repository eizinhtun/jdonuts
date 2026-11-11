import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class PointsRingPainter extends CustomPainter {
  const PointsRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 44.0;
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.ringTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final sweep = math.pi * 2 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.donutPink, AppColors.pink],
        ).createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    _paintIcingEdge(canvas, bounds, sweep, radius);
    _paintSprinkles(canvas, center, radius, sweep);
  }

  void _paintIcingEdge(
    Canvas canvas,
    Rect bounds,
    double sweep,
    double radius,
  ) {
    if (sweep <= 0) return;
    final edge = Paint()
      ..color = AppColors.pointsHighlightSoft.withValues(alpha: .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const edgeInset = 20.0;
    canvas.drawArc(
      Rect.fromCircle(center: bounds.center, radius: radius + edgeInset),
      -math.pi / 2,
      sweep,
      false,
      edge,
    );
    canvas.drawArc(
      Rect.fromCircle(center: bounds.center, radius: radius - edgeInset),
      -math.pi / 2,
      sweep,
      false,
      edge,
    );
  }

  void _paintSprinkles(
    Canvas canvas,
    Offset center,
    double radius,
    double sweep,
  ) {
    const colors = [
      AppColors.white,
      AppColors.pointsHighlight,
      AppColors.pointsGlow,
      AppColors.white,
    ];
    const count = 22;
    for (var index = 0; index < count; index++) {
      final fraction = (index + .5) / count;
      final angle = -math.pi / 2 + math.pi * 2 * fraction;
      if (angle + math.pi / 2 > sweep) continue;
      final position = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2 + (index.isEven ? .45 : -.35));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: index % 3 == 0 ? 5 : 4,
            height: index % 4 == 0 ? 15 : 11,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = colors[index % colors.length],
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PointsRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
