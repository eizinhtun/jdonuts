import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/tokens.dart';

/// Uses bundled vector/raster assets offline and disk cache for remote images.
class SeedImage extends StatelessWidget {
  const SeedImage({
    super.key,
    required this.assetName,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  });

  final String assetName;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(assetName);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return CachedNetworkImage(
        imageUrl: assetName,
        fit: fit,
        placeholder: (_, _) => const ColoredBox(color: AppColors.canvas),
        errorWidget: (_, _, _) => const _ImageFailure(),
      );
    }
    if (assetName.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        'assets/images/$assetName',
        fit: fit,
        semanticsLabel: semanticsLabel,
        placeholderBuilder: (_) => const ColoredBox(color: AppColors.canvas),
        errorBuilder: (_, _, _) => const _ImageFailure(),
      );
    }
    return Image.asset(
      'assets/images/$assetName',
      fit: fit,
      semanticLabel: semanticsLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null
          ? child
          : const ColoredBox(color: AppColors.canvas),
      errorBuilder: (_, _, _) => const _ImageFailure(),
    );
  }
}

class _ImageFailure extends StatelessWidget {
  const _ImageFailure();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.canvas,
    child: Center(child: Icon(Icons.broken_image_outlined)),
  );
}
