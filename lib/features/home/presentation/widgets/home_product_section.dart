import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/models.dart';

class HomeProductSection extends ConsumerWidget {
  const HomeProductSection({super.key, required this.section});
  final HomeSection section;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(sectionProductsProvider(section.id));
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 174,
            child: products.when(
              loading: () => const _SectionSkeleton(),
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
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    scrollDirection: Axis.horizontal,
    itemCount: 2,
    separatorBuilder: (_, _) => const SizedBox(width: 10),
    itemBuilder: (context, index) => const SizedBox(
      width: 128,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.skeletonBase,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
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
  const _ProductCard({required this.product, required this.heroTag});
  final Product product;
  final String heroTag;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/product/${product.id}', extra: heroTag),
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Hero(
                  tag: heroTag,
                  child: Container(
                    width: 128,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: SeedImage(assetName: product.image),
                  ),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      context.l10n.discountLabel(value),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
