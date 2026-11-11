import 'package:flutter/material.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/core/network/network_reachability.dart';
import 'package:jdonuts/l10n/localization.dart';
import 'package:jdonuts/core/theme/tokens.dart';

const _shopCardImage = 'jdonuts-shop-display.jpg';
const _shopHillBack = Color(0xFF9EB95A);
const _shopHillFront = Color(0xFF719548);
const _shopTree = Color(0xFF39764C);
const _shopGrass = Color(0xFFB1D943);
const _shopCloud = Color(0xFFFFF7EC);
const _shopCloudShade = Color(0xFFEED3AA);
const _shopCloudBlue = Color(0xFFBFE5DE);

class HomeShops extends StatelessWidget {
  const HomeShops({super.key, required this.shops});

  final List<String> shops;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width * .76).clamp(
      250.0,
      310.0,
    );
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = cardWidth * (textScale > 1.1 ? 1.05 : 1.0);
    return Container(
      margin: const EdgeInsets.only(top: AppSpace.sectionGap),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _ShopLandscapePainter()),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.lg,
                    AppSpace.md,
                    AppSpace.md,
                    0,
                  ),
                  child: Text(
                    context.l10n.shopsNear(shops.length),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.mdPlus),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpace.md),
                  child: _ExploreShopsButton(
                    onPressed: () => _showComingSoon(context),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                if (shops.isEmpty)
                  SizedBox(
                    height: cardHeight,
                    child: Center(
                      child: Text(
                        context.l10n.noNearbyShops,
                        style: const TextStyle(color: AppColors.ink),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: cardHeight,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.lg,
                      ),
                      itemCount: shops.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpace.sm),
                      itemBuilder: (context, index) => _NearbyShopCard(
                        name: shops[index],
                        width: cardWidth,
                        height: cardHeight,
                        onOrderOnline: () => _showComingSoon(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
  }
}

class _ExploreShopsButton extends StatelessWidget {
  const _ExploreShopsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          context.l10n.exploreNow,
          style: const TextStyle(
            color: AppColors.cyan,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}

class _NearbyShopCard extends StatelessWidget {
  const _NearbyShopCard({
    required this.name,
    required this.width,
    required this.height,
    required this.onOrderOnline,
  });

  final String name;
  final double width;
  final double height;
  final VoidCallback onOrderOnline;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.smPlus),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: double.infinity,
                height: (width - AppSpace.mdPlus) * .56,
                child: SeedImage(
                  assetName: _shopCardImage,
                  fit: BoxFit.cover,
                  semanticsLabel: name,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 13,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpace.xxs),
            Text(
              context.l10n.shopRegion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.bodyMuted,
                fontSize: 11,
                height: 1.15,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onOrderOnline,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  context.l10n.orderOnline,
                  style: const TextStyle(
                    color: AppColors.pink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShopLandscapePainter extends CustomPainter {
  const _ShopLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(AppColors.cyan, BlendMode.src);
    _drawCloud(
      canvas,
      Offset(size.width * 1.02, size.height * .09),
      size.width * .25,
      _shopCloudShade,
    );
    _drawCloud(
      canvas,
      Offset(size.width * .97, size.height * .2),
      size.width * .22,
      _shopCloud,
    );
    _drawCloud(
      canvas,
      Offset(size.width * .72, size.height * .5),
      size.width * .17,
      _shopCloud,
    );
    _drawCloud(
      canvas,
      Offset(-size.width * .03, size.height * .57),
      size.width * .13,
      _shopCloudBlue,
    );
    final backHill = Path()
      ..moveTo(0, size.height * .72)
      ..cubicTo(
        size.width * .2,
        size.height * .62,
        size.width * .33,
        size.height * .78,
        size.width * .52,
        size.height * .7,
      )
      ..cubicTo(
        size.width * .73,
        size.height * .6,
        size.width * .85,
        size.height * .69,
        size.width,
        size.height * .64,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(backHill, Paint()..color = _shopHillBack);

    final frontHill = Path()
      ..moveTo(0, size.height * .88)
      ..cubicTo(
        size.width * .24,
        size.height * .76,
        size.width * .45,
        size.height * .93,
        size.width * .63,
        size.height * .83,
      )
      ..cubicTo(
        size.width * .8,
        size.height * .75,
        size.width * .91,
        size.height * .86,
        size.width,
        size.height * .8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontHill, Paint()..color = _shopHillFront);

    for (final x in [size.width * .025, size.width * .12, size.width * .91]) {
      _drawTree(canvas, Offset(x, size.height * .84), size.shortestSide * .06);
    }
    final grassPaint = Paint()
      ..color = _shopGrass
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [size.width * .36, size.width * .41, size.width * .8]) {
      canvas.drawLine(
        Offset(x, size.height * .98),
        Offset(x + 3, size.height * .93),
        grassPaint,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Color color) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, Color.lerp(color, AppColors.white, .35)!],
        ).createShader(bounds),
    );
  }

  void _drawTree(Canvas canvas, Offset base, double scale) {
    final trunk = Paint()..color = _shopHillFront;
    canvas.drawRect(
      Rect.fromLTWH(
        base.dx - scale * .08,
        base.dy - scale * .55,
        scale * .16,
        scale * .55,
      ),
      trunk,
    );
    final leaves = Paint()..color = _shopTree;
    for (var level = 0; level < 3; level++) {
      final top = base.dy - scale * (.55 + level * .24);
      final halfWidth = scale * (.35 - level * .07);
      final path = Path()
        ..moveTo(base.dx, top - scale * .3)
        ..lineTo(base.dx - halfWidth, top + scale * .15)
        ..lineTo(base.dx + halfWidth, top + scale * .15)
        ..close();
      canvas.drawPath(path, leaves);
    }
  }

  @override
  bool shouldRepaint(covariant _ShopLandscapePainter oldDelegate) => false;
}

class HomeOfflineNotice extends StatelessWidget {
  const HomeOfflineNotice({super.key, required this.status});

  final NetworkStatus status;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpace.sm),
    child: Text(
      status.internetReachability == InternetReachability.unknown
          ? context.l10n.internetStatusUnknown
          : context.l10n.offlineNotice,
      textAlign: TextAlign.center,
      style: AppTypography.caption,
    ),
  );
}

class HomeStateMessage extends StatelessWidget {
  const HomeStateMessage({
    super.key,
    required this.title,
    required this.onRetry,
  });
  final String title;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        TextButton(onPressed: onRetry, child: Text(context.l10n.retryLabel)),
      ],
    ),
  );
}
