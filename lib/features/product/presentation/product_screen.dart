import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../main.dart';
import '../../home/domain/models.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});
  final String productId;
  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  int quantity = 1;
  bool added = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ref
          .watch(appDataProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(child: Text('Product unavailable')),
            data: (data) {
              final product = data.product(widget.productId);
              if (product == null)
                return const Center(child: Text('Product not found'));
              return _product(context, product);
            },
          ),
    ),
  );
  Widget _product(BuildContext context, Product product) => Column(
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
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'product-${product.id}',
                child: Container(
                  height: 285,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Image.asset('assets/images/${product.image}'),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 18,
                        child: Text(
                          product.code,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (product.isNew)
                        const Positioned(
                          right: 16,
                          top: 14,
                          child: _NewBadge(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(product.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(
                formatMmk(product.priceMmk),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(24),
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
              const SizedBox(height: 25),
              const Text(
                'What’s this?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: const TextStyle(color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
        child: FilledButton(
          onPressed: () {
            setState(() => added = true);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Added to cart')));
          },
          style: FilledButton.styleFrom(
            backgroundColor: added ? AppColors.orange : AppColors.cyan,
            minimumSize: const Size.fromHeight(54),
          ),
          child: Text(
            '${added ? 'ADDED' : 'ADD TO CART'}   ·   ${formatMmk(product.priceMmk * quantity)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ],
  );
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Text(
      'New',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
