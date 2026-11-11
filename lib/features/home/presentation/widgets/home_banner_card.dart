import 'package:flutter/material.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/core/theme/tokens.dart';

import '../../../home/domain/models.dart';

const _bannerPurple = AppColors.bannerPurple;
const _bannerBlue = AppColors.bannerCyan;

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key, required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isDiscount = banner.subtitle.contains('%');
      final background = isDiscount ? _bannerBlue : _bannerPurple;
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    background,
                    Color.lerp(background, AppColors.white, .1)!,
                  ],
                ),
              ),
            ),
            const CustomPaint(painter: _BannerPattern()),
            Positioned(
              left: 16,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  banner.subtitle,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 42,
              bottom: 8,
              width: constraints.maxWidth * .45,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.08,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              width: constraints.maxWidth * .48,
              height: constraints.maxHeight * .52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SeedImage(
                    assetName: banner.image,
                    fit: BoxFit.cover,
                    semanticsLabel: banner.title,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _BannerPattern extends CustomPainter {
  const _BannerPattern();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: .15)
      ..strokeWidth = size.shortestSide * .025
      ..strokeCap = StrokeCap.round;
    final marks = [
      Offset(.12, .18),
      Offset(.28, .4),
      Offset(.77, .16),
      Offset(.88, .72),
      Offset(.4, .82),
    ];
    for (final mark in marks) {
      canvas.drawLine(
        Offset(size.width * mark.dx, size.height * mark.dy),
        Offset(
          size.width * mark.dx + size.shortestSide * .045,
          size.height * mark.dy + size.shortestSide * .025,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BannerPattern oldDelegate) => false;
}
