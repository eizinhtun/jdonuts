import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonuts/app/route_observer.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  final _pager = PageController(viewportFraction: .92);
  Timer? _carousel;
  ModalRoute<dynamic>? _route;
  bool? _reduceMotion;
  bool _isDragging = false;
  bool _routeIsVisible = true;
  bool _appIsResumed = true;
  bool _autoplayCheckPending = false;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _appIsResumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _routeIsVisible = route.isCurrent;
      }
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _pauseAutoplay(interruptAnimation: true);
    } else {
      _scheduleAutoplay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    if (_appIsResumed) {
      _scheduleAutoplay();
    } else {
      _pauseAutoplay(interruptAnimation: true);
    }
  }

  @override
  void didPush() {
    _routeIsVisible = true;
    _scheduleAutoplay();
  }

  @override
  void didPushNext() {
    _routeIsVisible = false;
    _pauseAutoplay(interruptAnimation: true);
  }

  @override
  void didPopNext() {
    _routeIsVisible = true;
    _scheduleAutoplay();
  }

  @override
  void didPop() {
    _routeIsVisible = false;
    _pauseAutoplay(interruptAnimation: true);
  }

  bool get _canAutoplay =>
      mounted &&
      _reduceMotion == false &&
      _routeIsVisible &&
      _appIsResumed &&
      !_isDragging;

  void _scheduleAutoplay() {
    if (!_canAutoplay ||
        _isAutoScrolling ||
        _carousel != null ||
        !_pager.hasClients) {
      return;
    }
    final bannerCount =
        ref.read(appDataProvider).asData?.value.banners.length ?? 0;
    if (bannerCount < 2) return;
    _carousel = Timer(Motion.carousel, () {
      _carousel = null;
      unawaited(_advanceCarousel());
    });
  }

  void _scheduleAutoplayAfterLayout() {
    if (_autoplayCheckPending) return;
    _autoplayCheckPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoplayCheckPending = false;
      if (mounted) _scheduleAutoplay();
    });
  }

  Future<void> _advanceCarousel() async {
    final bannerCount =
        ref.read(appDataProvider).asData?.value.banners.length ?? 0;
    if (!_canAutoplay ||
        _isAutoScrolling ||
        !_pager.hasClients ||
        bannerCount < 2) {
      return;
    }
    final next = ((_pager.page ?? 0).round() + 1) % bannerCount;
    _isAutoScrolling = true;
    try {
      await _pager.animateToPage(
        next,
        duration: Motion.duration(context, Motion.standard),
        curve: Motion.curve,
      );
    } finally {
      _isAutoScrolling = false;
      if (mounted) _scheduleAutoplayAfterLayout();
    }
  }

  void _pauseAutoplay({bool interruptAnimation = false}) {
    _carousel?.cancel();
    _carousel = null;
    if (interruptAnimation && !_isDragging && _pager.hasClients) {
      final position = _pager.position;
      if (position.isScrollingNotifier.value) {
        _pager.jumpToPage((_pager.page ?? 0).round());
      }
    }
  }

  bool _onBannerScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _isDragging = true;
      _pauseAutoplay();
    } else if (notification is ScrollEndNotification && _isDragging) {
      _isDragging = false;
      _scheduleAutoplay();
    }
    return false;
  }

  @override
  void dispose() {
    _carousel?.cancel();
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
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
    _scheduleAutoplayAfterLayout();
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
                            child: NotificationListener<ScrollNotification>(
                              onNotification: _onBannerScroll,
                              child: PageView(
                                controller: _pager,
                                children: data.banners
                                    .map(
                                      (banner) =>
                                          HomeBannerCard(banner: banner),
                                    )
                                    .toList(),
                              ),
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
