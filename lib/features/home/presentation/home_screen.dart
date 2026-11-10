import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../app/providers.dart';
import '../domain/models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pager = PageController(viewportFraction: .88);
  Timer? _carousel;
  bool? _reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    _carousel?.cancel();
    _carousel = reduceMotion
        ? null
        : Timer.periodic(Motion.carousel, (_) {
            final bannerCount =
                ref.read(appDataProvider).asData?.value.banners.length ?? 0;
            if (!mounted || !_pager.hasClients || bannerCount < 2) return;
            final next = (((_pager.page ?? 0).round() + 1) % bannerCount)
                .toInt();
            _pager.animateToPage(
              next,
              duration: Motion.duration(context, Motion.standard),
              curve: Motion.curve,
            );
          });
  }

  @override
  void dispose() {
    _carousel?.cancel();
    _pager.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final result = await ref.read(dataRepositoryProvider).refresh();
    if (!mounted) return;
    result.fold<void>(
      (_) => ref.invalidate(appDataProvider),
      (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      if (previous?.asData?.value == false && next.asData?.value == true) {
        unawaited(_refresh());
      }
    });
    final online = ref.watch(connectivityProvider).asData?.value ?? false;
    return Scaffold(
      body: SafeArea(
        child: ref
            .watch(appDataProvider)
            .when(
              loading: () => const _HomeSkeleton(),
              error: (e, _) => _StateMessage(
                title: context.l10n.homeLoadError,
                onRetry: _refresh,
              ),
              data: (data) => RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: AnimatedEntrance(
                        child: _Header(member: data.member),
                      ),
                    ),
                    if (!online)
                      const SliverToBoxAdapter(child: _OfflineNotice()),
                    SliverToBoxAdapter(
                      child: AnimatedEntrance(
                        delay: const Duration(milliseconds: 70),
                        child: SizedBox(
                          height: 160,
                          child: PageView(
                            controller: _pager,
                            children: data.banners
                                .map(
                                  (b) => _BannerCard(
                                    title: b.title,
                                    subtitle: b.subtitle,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    for (var index = 0; index < data.sections.length; index++)
                      SliverToBoxAdapter(
                        child: AnimatedEntrance(
                          delay: Duration(milliseconds: 110 + index * 60),
                          child: _ProductSection(
                            section: data.sections[index],
                            data: data,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: AnimatedEntrance(
                        delay: const Duration(milliseconds: 270),
                        child: _shops(context, data.shops),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  ],
                ),
              ),
            ),
      ),
      bottomNavigationBar: const AppBottomNav(selected: 0),
    );
  }
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
                context.l10n.memberTierLabel(member.tier),
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.homeGoldProgress(member.pointsToGold),
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Badge(
            label: Text(context.l10n.notificationCount(member.notifications)),
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
          const SeedImage(assetName: 'banner.svg', fit: BoxFit.cover),
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
  final HomeSection section;
  final AppData data;
  @override
  Widget build(BuildContext context) {
    final products = section.productIds
        .map(data.product)
        .whereType<Product>()
        .toList();
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
            child: products.isEmpty
                ? Center(child: Text(context.l10n.emptyProducts))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => _ProductCard(
                      product: products[index],
                      heroTag: 'product-${products[index].id}-${section.id}',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
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

Widget _shops(BuildContext context, List<String> shops) => Container(
  margin: const EdgeInsets.only(top: 18),
  padding: const EdgeInsets.all(18),
  color: AppColors.cyan,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.shopsNear(shops.length),
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      context.l10n.offlineNotice,
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
        TextButton(onPressed: onRetry, child: Text(context.l10n.retryLabel)),
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
      if (index == 0) {
        context.go('/home');
      } else if (index == 2) {
        context.go('/rewards');
      } else if (index == 4) {
        context.push('/settings');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
      }
    },
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        label: context.l10n.homeLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_offer_outlined),
        label: context.l10n.offersLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.stars_outlined),
        label: context.l10n.rewardsLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.shopping_bag_outlined),
        label: context.l10n.orderLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        label: context.l10n.profileLabel,
      ),
    ],
  );
}
