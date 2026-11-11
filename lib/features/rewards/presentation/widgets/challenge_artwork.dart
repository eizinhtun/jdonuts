import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class ChallengeArtwork extends StatelessWidget {
  const ChallengeArtwork({
    super.key,
    required this.kind,
    required this.progress,
  });

  final String kind;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final target = progress.isFinite
        ? progress.clamp(0.0, 1.0).toDouble()
        : 0.0;
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: Motion.duration(context, Motion.rewardArtwork),
        curve: Motion.rewardProgressCurve,
        builder: (context, animatedProgress, _) => RepaintBoundary(
          child: kind == 'donut'
              ? _DonutProgress(progress: animatedProgress)
              : _CoffeeProgress(progress: animatedProgress),
        ),
      ),
    );
  }
}

class _DonutProgress extends StatelessWidget {
  const _DonutProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0).toDouble();
    if (value == 1) return _donutImage();
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscale),
          child: _donutImage(),
        ),
        if (value > 0)
          ClipPath(clipper: _DonutWedgeClipper(value), child: _donutImage()),
      ],
    );
  }

  Widget _donutImage() => Image.asset(
    'assets/images/onboarding-hero-donut.png',
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => const Center(
      child: Icon(Icons.donut_large, color: AppColors.donutPink, size: 72),
    ),
  );

  static const _grayscale = <double>[
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];
}

class _DonutWedgeClipper extends CustomClipper<Path> {
  const _DonutWedgeClipper(this.progress);

  final double progress;

  @override
  Path getClip(Size size) {
    final bounds = Offset.zero & size;
    final center = bounds.center;
    final path = Path()..moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(
        center: center,
        radius: math.min(size.width, size.height) / 2,
      ),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
    );
    return path..close();
  }

  @override
  bool shouldReclip(covariant _DonutWedgeClipper oldClipper) =>
      oldClipper.progress != progress;
}

class _CoffeeProgress extends StatelessWidget {
  const _CoffeeProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CoffeeArcPainter(progress: progress),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Image.asset(
          'assets/images/dalgona-coffee.png',
          width: 64,
          height: 84,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.local_cafe_outlined,
            size: 58,
            color: AppColors.coffeeBrown,
          ),
        ),
      ),
    ),
  );
}

class _CoffeeArcPainter extends CustomPainter {
  const _CoffeeArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .56);
    final radius = math.min(size.width * .42, size.height * .44);
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = AppColors.canvas
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(bounds, math.pi, math.pi, false, track);
    canvas.drawArc(
      bounds,
      math.pi,
      math.pi * progress.clamp(0.0, 1.0).toDouble(),
      false,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CoffeeArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
