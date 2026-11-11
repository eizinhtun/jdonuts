import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';
import 'package:jdonuts/core/theme/tokens.dart';

import '../../../../app/providers.dart';
import '../../domain/models.dart';

class HomeProductSection extends ConsumerWidget {
  const HomeProductSection({super.key, required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(sectionProductsProvider(section.id));
    final width = MediaQuery.sizeOf(context).width;
    final seasonal = section.id == 'seasonal';
    final popular = section.id == 'popular';
    final cardWidth = width * (seasonal ? .61 : .42);
    final artworkHeight = seasonal
        ? cardWidth * .64
        : popular
        ? cardWidth * 1.24
        : cardWidth;
    final cardHeight = artworkHeight + 52;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          section.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (popular) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.local_fire_department,
                          size: 18,
                          color: AppColors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: cardHeight,
            child: products.when(
              loading: () => _SectionSkeleton(
                cardWidth: cardWidth,
                artworkHeight: artworkHeight,
              ),
              error: (_, _) => _SectionState(
                label: context.l10n.sectionUnavailable,
                actionLabel: context.l10n.retryLabel,
                onPressed: () =>
                    ref.invalidate(sectionProductsProvider(section.id)),
              ),
              data: (items) => items.isEmpty
                  ? Center(child: Text(context.l10n.emptyProducts))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => _ProductCard(
                        product: items[index],
                        heroTag: 'product-${items[index].id}-${section.id}',
                        width: cardWidth,
                        artworkHeight: artworkHeight,
                        seasonal: seasonal,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({
    required this.cardWidth,
    required this.artworkHeight,
  });

  final double cardWidth;
  final double artworkHeight;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    scrollDirection: Axis.horizontal,
    itemCount: 2,
    separatorBuilder: (_, _) => const SizedBox(width: 10),
    itemBuilder: (context, index) => SizedBox(
      width: cardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.skeletonBase,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(height: artworkHeight),
      ),
    ),
  );
}

class _SectionState extends StatelessWidget {
  const _SectionState({
    required this.label,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.heroTag,
    required this.width,
    required this.artworkHeight,
    required this.seasonal,
  });

  final Product product;
  final String heroTag;
  final double width;
  final double artworkHeight;
  final bool seasonal;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/product/${product.id}', extra: heroTag),
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: artworkHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (seasonal)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _heroImage(context, fit: BoxFit.cover),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: _heroImage(context),
                  ),
                if (product.discountPercent != null)
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: _DiscountBadge(value: product.discountPercent!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _heroImage(BuildContext context, {BoxFit fit = BoxFit.contain}) {
    final image = SeedImage(
      assetName: product.image,
      fit: fit,
      semanticsLabel: product.name,
    );
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(tag: heroTag, child: image),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Text(
      context.l10n.discountLabel(value),
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
