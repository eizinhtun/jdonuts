import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../app/providers.dart';
import '../../../core/formatters/currency.dart';
import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../home/domain/models.dart';

const _helpGreen = Color(0xFF83BF49);

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
            error: (_, _) => _productIssue(
              context,
              context.l10n.productUnavailable,
              onRetry: () => ref.invalidate(productProvider(widget.productId)),
            ),
            data: (product) {
              if (product == null) {
                return _productIssue(context, context.l10n.productNotFound);
              }
              return _product(context, product);
            },
          ),
    ),
  );

  Widget _productIssue(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text(context.l10n.retryLabel)),
        TextButton(
          onPressed: () => context.go('/home'),
          child: Text(context.l10n.homeLabel),
        ),
      ],
    ),
  );

  Widget _product(BuildContext context, Product product) => LayoutBuilder(
    builder: (context, constraints) {
      final cardHeight = (constraints.maxHeight * .58).clamp(370.0, 450.0);
      return Column(
        children: [
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back),
                iconSize: 24,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProductHeroCard(
                    product: product,
                    heroTag: widget.heroTag,
                    height: cardHeight,
                    imageWidth: (constraints.maxWidth * .72).clamp(
                      220.0,
                      290.0,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -34),
                    child: Center(
                      child: _QuantityStepper(
                        quantity: quantity,
                        onDecrease: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        onIncrease: () => setState(() => quantity++),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 8),
                    child: _ProductDescription(product: product),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 6, 28, 10),
            child: _AddToCartButton(
              product: product,
              quantity: quantity,
              added: added,
              onPressed: () {
                setState(() => added = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.addedToCart)),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

class _ProductHeroCard extends StatelessWidget {
  const _ProductHeroCard({
    required this.product,
    required this.heroTag,
    required this.height,
    required this.imageWidth,
  });

  final Product product;
  final String heroTag;
  final double height;
  final double imageWidth;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
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
              style: const TextStyle(color: Color(0xFF8996A3), fontSize: 13),
            ),
            if (product.isNew) _NewBadge(label: context.l10n.newBadge),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatMmk(product.priceMmk),
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: SizedBox(
                width: imageWidth,
                height: 266,
                child: HeroMode(
                  enabled: !MediaQuery.disableAnimationsOf(context),
                  child: Hero(
                    tag: heroTag,
                    child: SeedImage(
                      assetName: product.image,
                      semanticsLabel: product.name,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.canvas,
      borderRadius: BorderRadius.circular(36),
      border: Border.all(color: AppColors.white, width: 2),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrease,
          tooltip: context.l10n.decreaseQuantity,
          icon: const Icon(Icons.remove_circle, color: AppColors.cyan),
          iconSize: 38,
          constraints: const BoxConstraints.tightFor(width: 54, height: 52),
          padding: EdgeInsets.zero,
        ),
        SizedBox(
          width: 46,
          child: AnimatedSwitcher(
            duration: Motion.duration(context, Motion.quick),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF303A43),
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onIncrease,
          tooltip: context.l10n.increaseQuantity,
          icon: const Icon(Icons.add_circle, color: AppColors.cyan),
          iconSize: 38,
          constraints: const BoxConstraints.tightFor(width: 54, height: 52),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 64,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help, color: _helpGreen, size: 18),
              const SizedBox(height: 5),
              Text(
                context.l10n.whatsThis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const VerticalDivider(width: 1, thickness: 1, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            product.description,
            style: const TextStyle(
              color: Color(0xFF7D8286),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.product,
    required this.quantity,
    required this.added,
    required this.onPressed,
  });

  final Product product;
  final int quantity;
  final bool added;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final compact =
        MediaQuery.sizeOf(context).width < 380 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.1;
    final fontSize = compact ? 12.0 : 15.0;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: added ? AppColors.orange : AppColors.cyan,
        minimumSize: const Size.fromHeight(56),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 12),
        shape: const StadiumBorder(),
      ),
      child: AnimatedSwitcher(
        duration: Motion.duration(context, Motion.quick),
        child: Row(
          key: ValueKey('$added-$quantity'),
          children: [
            Expanded(
              child: Text(
                added ? context.l10n.addedLabel : context.l10n.addToCart,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: compact ? .1 : .4,
                ),
              ),
            ),
            Container(
              width: 1,
              height: compact ? 22 : 25,
              margin: EdgeInsets.symmetric(horizontal: compact ? 5 : 10),
              color: Colors.white.withValues(alpha: .65),
            ),
            Expanded(
              child: Text(
                formatMmk(product.priceMmk * quantity),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: compact ? .1 : .4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
