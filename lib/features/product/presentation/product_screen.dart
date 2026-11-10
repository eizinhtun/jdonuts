import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../app/providers.dart';
import '../../../core/formatters/currency.dart';
import '../../home/domain/models.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({
    super.key,
    required this.productId,
    required this.heroTag,
  });
  final String productId;
  final String heroTag;
  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int quantity = 1;
  bool added = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.canvas,
    body: SafeArea(
      child: ref
          .watch(productProvider(widget.productId))
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(
                value: MediaQuery.disableAnimationsOf(context) ? .65 : null,
              ),
            ),
            error: (_, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.productUnavailable),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(productProvider(widget.productId)),
                    child: Text(context.l10n.retryLabel),
                  ),
                ],
              ),
            ),
            data: (product) {
              if (product == null) {
                return Center(child: Text(context.l10n.productNotFound));
              }
              return _product(context, product);
            },
          ),
    ),
  );
  Widget _product(BuildContext context, Product product) => LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = (constraints.maxHeight * .43).clamp(300.0, 390.0);
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: cardHeight,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.code,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            if (product.isNew)
                              _NewBadge(label: context.l10n.newBadge),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatMmk(product.priceMmk),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Hero(
                            tag: widget.heroTag,
                            child: SeedImage(
                              assetName: product.image,
                              semanticsLabel: product.name,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(
                                Icons.remove_circle,
                                color: AppColors.cyan,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: Motion.duration(context, Motion.quick),
                              child: Text(
                                '$quantity',
                                key: ValueKey(quantity),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: const Icon(
                                Icons.add_circle,
                                color: AppColors.cyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3, right: 10),
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF70B84B),
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.whatsThis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                product.description,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
            child: FilledButton(
              onPressed: () {
                setState(() => added = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.addedToCart)),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: added ? AppColors.orange : AppColors.cyan,
                minimumSize: const Size.fromHeight(54),
                shape: const StadiumBorder(),
              ),
              child: AnimatedSwitcher(
                duration: Motion.duration(context, Motion.quick),
                child: Text(
                  context.l10n.cartTotal(
                    added ? context.l10n.addedLabel : context.l10n.addToCart,
                    formatMmk(product.priceMmk * quantity),
                  ),
                  key: ValueKey('$added-$quantity'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
