import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../app/providers.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/home_banner_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_product_section.dart';
import 'widgets/home_shops.dart';
import 'widgets/home_skeleton.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pager = PageController(viewportFraction: .92);
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
      backgroundColor: const Color(0xFFFFEEE0),
      body: SafeArea(
        child: ColoredBox(
          color: AppColors.canvas,
          child: ref
              .watch(appDataProvider)
              .when(
                loading: () => const HomeSkeleton(),
                error: (e, _) => HomeStateMessage(
                  title: context.l10n.homeLoadError,
                  onRetry: _refresh,
                ),
                data: (data) => RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: AnimatedEntrance(
                          child: HomeHeader(member: data.member),
                        ),
                      ),
                      if (!online)
                        const SliverToBoxAdapter(child: HomeOfflineNotice()),
                      SliverToBoxAdapter(
                        child: AnimatedEntrance(
                          delay: Motion.homeBannerDelay,
                          child: SizedBox(
                            height: (MediaQuery.sizeOf(context).width * .44)
                                .clamp(142.0, 178.0),
                            child: PageView(
                              controller: _pager,
                              children: data.banners
                                  .map(
                                    (banner) => HomeBannerCard(banner: banner),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      for (var index = 0; index < data.sections.length; index++)
                        SliverToBoxAdapter(
                          child: AnimatedEntrance(
                            delay: Motion.homeSectionDelay(index),
                            child: HomeProductSection(
                              section: data.sections[index],
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: AnimatedEntrance(
                          delay: Motion.homeShopsDelay,
                          child: HomeShops(shops: data.shops),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    ],
                  ),
                ),
              ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selected: 0, homeStyle: true),
    );
  }
}
