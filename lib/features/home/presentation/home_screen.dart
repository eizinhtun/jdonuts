import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../main.dart';
import '../domain/models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pager = PageController(viewportFraction: .88);
  Timer? _carousel;
  bool _online = true;
  @override
  void initState() {
    super.initState();
    _carousel = Timer.periodic(Motion.carousel, (_) {
      if (mounted &&
          _pager.hasClients &&
          !MediaQuery.disableAnimationsOf(context)) {
        final next = ((_pager.page ?? 0).round() + 1) % 2;
        _pager.animateToPage(
          next,
          duration: Motion.standard,
          curve: Motion.curve,
        );
      }
    });
  }

  @override
  void dispose() {
    _carousel?.cancel();
    _pager.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(dataRepositoryProvider).refresh();
    ref.invalidate(appDataProvider);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ref
          .watch(appDataProvider)
          .when(
            loading: () => const _HomeSkeleton(),
            error: (e, _) => _StateMessage(
              title: 'Couldn’t load your home',
              onRetry: _refresh,
            ),
            data: (data) => RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(member: data.member)),
                  if (!_online)
                    const SliverToBoxAdapter(child: _OfflineNotice()),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: PageView(
                        controller: _pager,
                        children: data.banners
                            .map(
                              (b) => _BannerCard(
                                title: b['title'] as String,
                                subtitle: b['subtitle'] as String,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  for (final section in data.sections)
                    SliverToBoxAdapter(
                      child: _ProductSection(section: section, data: data),
                    ),
                  SliverToBoxAdapter(child: _shops(data.shops)),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                ],
              ),
            ),
          ),
    ),
    bottomNavigationBar: const AppBottomNav(selected: 0),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.member});
  final Member member;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFFFD5E2),
          child: Text(
            member.name.characters.first,
            style: const TextStyle(
              color: AppColors.pink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${member.tier} member',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${member.pointsToGold} points left to become Gold Member',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Badge(
            label: Text('${member.notifications}'),
            child: const Icon(Icons.notifications_none),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
  );
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/banner.svg', fit: BoxFit.cover),
          Positioned(
            left: 24,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  width: 210,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({required this.section, required this.data});
  final Map<String, dynamic> section;
  final AppData data;
  @override
  Widget build(BuildContext context) {
    final ids = (section['productIds'] as List).cast<String>();
    final products = ids.map(data.product).whereType<Product>().toList();
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
                    section['title'] as String,
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
            child: products.isEmpty
                ? const Center(child: Text('No items yet'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) =>
                        _ProductCard(product: products[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/product/${product.id}'),
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: 128,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/images/${product.image}',
                    fit: BoxFit.contain,
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
      '$value% off',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _shops(List<String> shops) => Container(
  margin: const EdgeInsets.only(top: 18),
  padding: const EdgeInsets.all(18),
  color: AppColors.cyan,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'There are 4 J’Donut shops near you',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      for (final shop in shops)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront_outlined),
              const SizedBox(width: 10),
              Expanded(child: Text(shop)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
    ],
  ),
);

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(8),
    child: Text(
      'You’re offline — showing saved items',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.muted, fontSize: 12),
    ),
  );
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, required this.onRetry});
  final String title;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: List.generate(
      5,
      (i) => Container(
        height: i == 0 ? 56 : 150,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selected,
    onDestinationSelected: (index) {
      if (index == 0)
        context.go('/home');
      else if (index == 2)
        context.go('/rewards');
      else if (index == 4)
        context.push('/settings');
      else
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This section is coming soon.')),
        );
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(
        icon: Icon(Icons.local_offer_outlined),
        label: 'Offer',
      ),
      NavigationDestination(icon: Icon(Icons.stars_outlined), label: 'Reward'),
      NavigationDestination(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Order',
      ),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ],
  );
}
