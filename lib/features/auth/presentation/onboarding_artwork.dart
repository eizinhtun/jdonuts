import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/core/theme/tokens.dart';

/// A local composition built from bundled artwork; the PDF collage isn't shipped.
class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final heroSize = width * .56;
      final heroTop = height * .18;
      return ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -width * .41,
              top: -height * .12,
              child: AnimatedEntrance(
                beginOffset: const Offset(-Motion.onboardingArtDrift, 0),
                child: _ArtBubble(
                  size: width * .62,
                  color: const Color(0xFF48CDE2),
                  image: 'chocolate-donut.png',
                  opacity: .25,
                  rotation: -.42,
                ),
              ),
            ),
            Positioned(
              right: -width * .27,
              top: -height * .12,
              child: AnimatedEntrance(
                delay: Motion.onboardingArtStagger,
                beginOffset: const Offset(Motion.onboardingArtDrift, 0),
                child: _ArtBubble(
                  size: width * .43,
                  color: const Color(0xFFC7E0F0),
                  image: 'strawberry.svg',
                  opacity: .56,
                  rotation: .48,
                  lowerColor: const Color(0xFFF8D5E2),
                ),
              ),
            ),
            Positioned(
              left: -width * .19,
              top: height * .48,
              child: AnimatedEntrance(
                delay: Motion.onboardingArtStagger * 2,
                beginOffset: Offset(-Motion.onboardingArtDrift, 0),
                child: _ArtBubble(
                  size: width * .4,
                  color: const Color(0xFFBFD8EF),
                  image: 'coconut.svg',
                  opacity: .82,
                  rotation: -.35,
                ),
              ),
            ),
            Positioned(
              right: -width * .27,
              top: height * .43,
              child: AnimatedEntrance(
                delay: Motion.onboardingArtStagger * 3,
                beginOffset: Offset(Motion.onboardingArtDrift, 0),
                child: _ArtBubble(
                  size: width * .42,
                  color: const Color(0xFFAECFED),
                  image: 'strawberry.svg',
                  opacity: .78,
                  rotation: .32,
                ),
              ),
            ),
            Positioned(
              left: (width - heroSize) / 2,
              top: heroTop,
              child: AnimatedEntrance(
                delay: Motion.onboardingHeroDelay,
                beginOffset: const Offset(0, -Motion.onboardingArtDrift),
                child: _HeroHalo(size: heroSize),
              ),
            ),
            Positioned(
              left: (width - heroSize) / 2,
              top: heroTop + heroSize * .18,
              child: AnimatedEntrance(
                delay: Motion.onboardingHeroDelay,
                beginOffset: const Offset(0, -Motion.onboardingArtDrift),
                child: SizedBox(
                  width: heroSize,
                  height: heroSize * .68,
                  child: Transform.rotate(
                    angle: .08,
                    child: const SeedImage(
                      assetName: 'onboarding-hero-donut.png',
                      semanticsLabel: 'Pink iced donut with sprinkles',
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: (width - width * .48) / 2,
              top: height * .76,
              child: AnimatedEntrance(
                delay: Motion.onboardingArtStagger * 4,
                beginOffset: const Offset(0, Motion.onboardingArtDrift),
                child: _ArtBubble(
                  size: width * .48,
                  color: const Color(0xFFFFD58B),
                  image: 'coconut.svg',
                  opacity: .2,
                  rotation: -.12,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * .22,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFF7FA), Color(0xFFFFF7FA)],
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

class _HeroHalo extends StatelessWidget {
  const _HeroHalo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, .54, .72, 1],
                colors: [
                  Color(0xFFF9DFD2),
                  Color(0xFFF9DFD2),
                  Color(0xFFF5B1C9),
                  Color(0xFFF5B1C9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: .12),
                  blurRadius: 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
          ),
        ),
        Positioned(left: size * .13, top: size * .31, child: _Sprinkle(size)),
        Positioned(
          left: size * .47,
          top: size * .1,
          child: Transform.rotate(angle: -.16, child: _Sprinkle(size)),
        ),
        Positioned(
          right: size * .15,
          top: size * .43,
          child: Transform.rotate(angle: .13, child: _Sprinkle(size)),
        ),
        Positioned(
          left: size * .15,
          bottom: size * .18,
          child: Transform.rotate(angle: .32, child: _Sprinkle(size)),
        ),
      ],
    ),
  );
}

class _Sprinkle extends StatelessWidget {
  const _Sprinkle(this.diameter);

  final double diameter;

  @override
  Widget build(BuildContext context) => Container(
    width: diameter * .025,
    height: diameter * .14,
    decoration: BoxDecoration(
      color: AppColors.pink.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _ArtBubble extends StatelessWidget {
  const _ArtBubble({
    required this.size,
    required this.color,
    required this.image,
    required this.opacity,
    required this.rotation,
    this.lowerColor,
  });

  final double size;
  final Color color;
  final String image;
  final double opacity;
  final double rotation;
  final Color? lowerColor;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: ClipOval(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, lowerColor ?? color.withValues(alpha: .55)],
          ),
        ),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: rotation,
            child: Padding(
              padding: EdgeInsets.all(size * .12),
              child: image.endsWith('.svg')
                  ? SvgPicture.asset(
                      'assets/images/$image',
                      fit: BoxFit.contain,
                    )
                  : SeedImage(assetName: image, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    ),
  );
}
