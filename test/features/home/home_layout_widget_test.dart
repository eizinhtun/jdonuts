import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/network/network_reachability.dart';
import 'package:jdonuts/app/route_observer.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/home/domain/home_repository.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/home/presentation/home_screen.dart';
import 'package:jdonuts/features/product/presentation/product_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('home dock fits at the label width breakpoint', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(388, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_homeWithBanners(_sampleData, reduceMotion: true));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    final renderError = tester.takeException();
    expect(renderError, isNull, reason: '$renderError');
  });

  testWidgets('banner autoplay waits for and yields to manual swipes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 850);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final data = _dataWithBanners(3);

    await tester.pumpWidget(_homeWithBanners(data));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(_bannerPage(tester), 0);

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(_bannerPage(tester), 1);

    await tester.pump(const Duration(milliseconds: 4500));
    expect(_bannerPage(tester), 1);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_bannerPage(tester), 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion leaves the banner carousel at its current page', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 850);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final data = _dataWithBanners(3);

    await tester.pumpWidget(_homeWithBanners(data, reduceMotion: true));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 12));

    expect(_bannerPage(tester), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('banner autoplay pauses while Home is covered by another route', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 850);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final data = _dataWithBanners(3);
    final router = GoRouter(
      initialLocation: '/home',
      observers: [appRouteObserver],
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/other',
          builder: (_, _) => const Scaffold(body: Text('Other route')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDataProvider.overrideWith((ref) async => data),
          dataRepositoryProvider.overrideWith(
            (ref) => _FakeDataRepository(data),
          ),
          connectivityProvider.overrideWith(
            (ref) => Stream.value(NetworkStatus.online),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    router.push('/other');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Other route'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(_bannerPage(tester), 0);

    await tester.pump(const Duration(milliseconds: 4500));
    expect(_bannerPage(tester), 0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_bannerPage(tester), 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty section does not hide populated Home sections', (
    tester,
  ) async {
    _disableMotion(tester);
    final emptySeasonalData = AppData(
      member: _sampleData.member,
      products: _sampleData.products,
      sections: _sampleData.sections
          .map(
            (section) => section.id == 'seasonal'
                ? HomeSection(
                    id: section.id,
                    title: section.title,
                    productIds: const [],
                  )
                : section,
          )
          .toList(),
      banners: _sampleData.banners,
      shops: _sampleData.shops,
      challenges: _sampleData.challenges,
    );
    final repository = _FakeDataRepository(emptySeasonalData);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDataProvider.overrideWith((ref) async => emptySeasonalData),
          dataRepositoryProvider.overrideWith((ref) => repository),
          connectivityProvider.overrideWith(
            (ref) => Stream.value(NetworkStatus.online),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Coconut Donut'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a failed Home section retries without replacing other sections',
    (tester) async {
      _disableMotion(tester);
      final repository = _FakeDataRepository(
        _sampleData,
        failedSections: {'seasonal': 1},
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDataProvider.overrideWith((ref) async => _sampleData),
            dataRepositoryProvider.overrideWith((ref) => repository),
            connectivityProvider.overrideWith(
              (ref) => Stream.value(NetworkStatus.online),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.sectionLoads['seasonal'], 1);
      expect(find.text('This section couldn’t load.'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('Popular'), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(find.text('This section couldn’t load.'), findsNothing);
      expect(find.text('Coconut Donut'), findsWidgets);
    },
  );

  testWidgets('refresh failure leaves cached Home usable', (tester) async {
    _disableMotion(tester);
    final changes = StreamController<NetworkStatus>();
    final repository = _FakeDataRepository(_sampleData)..failNextRefresh = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDataProvider.overrideWith((ref) async => _sampleData),
          dataRepositoryProvider.overrideWith((ref) => repository),
          connectivityProvider.overrideWith((ref) => changes.stream),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );

    try {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      changes.add(NetworkStatus.offline);
      await tester.pump();
      changes.add(NetworkStatus.online);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.refreshes, 1);
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Seasonal specials'), findsOneWidget);
      expect(find.text('Coconut Donut'), findsWidgets);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      unawaited(changes.close());
    }
  });

  testWidgets('Home coalesces reconnect and pull-to-refresh requests', (
    tester,
  ) async {
    _disableMotion(tester);
    final changes = StreamController<NetworkStatus>();
    final repository = _FakeDataRepository(_sampleData)
      ..refreshGate = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDataProvider.overrideWith((ref) async => _sampleData),
          dataRepositoryProvider.overrideWith((ref) => repository),
          connectivityProvider.overrideWith((ref) => changes.stream),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );

    try {
      await tester.pumpAndSettle();
      changes.add(const NetworkStatus.unknown());
      await tester.pump();
      await tester.pump();
      changes.add(NetworkStatus.online);
      await tester.pumpAndSettle();
      expect(repository.refreshes, 1);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(repository.refreshes, 1);

      repository.refreshGate!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      if (!(repository.refreshGate?.isCompleted ?? true)) {
        repository.refreshGate!.complete();
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      unawaited(changes.close());
    }
  });

  testWidgets(
    'offline Home reconnects and product fits a small portrait view',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 667);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final changes = StreamController<NetworkStatus>();
      final repository = _FakeDataRepository(_sampleData);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => _scaledScreen(const HomeScreen()),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (_, state) => _scaledScreen(
              ProductScreen(
                productId: state.pathParameters['id']!,
                heroTag: state.extra as String,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDataProvider.overrideWith((ref) async => _sampleData),
            dataRepositoryProvider.overrideWith((ref) => repository),
            connectivityProvider.overrideWith((ref) => changes.stream),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      try {
        await tester.pumpAndSettle();
        changes.add(NetworkStatus.offline);
        await tester.pump();
        await tester.pump();
        expect(
          find.text('You’re offline — showing saved items'),
          findsOneWidget,
        );

        changes.add(NetworkStatus.online);
        await tester.pumpAndSettle();
        expect(repository.refreshes, 1);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
        await tester.pumpAndSettle();
        expect(repository.refreshes, 2);

        await tester.ensureVisible(find.text('Coconut Donut').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Coconut Donut').first);
        await tester.pumpAndSettle();
        expect(find.text('JD022123'), findsOneWidget);
        expect(find.text('3,200 MMK'), findsNWidgets(2));
        expect(find.text('New'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add_circle));
        await tester.pumpAndSettle();
        expect(find.text('2'), findsOneWidget);
        expect(find.textContaining('6,400 MMK'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.remove_circle));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.remove_circle));
        await tester.pumpAndSettle();
        expect(find.text('1'), findsOneWidget);
        await tester.tap(find.textContaining('ADD TO CART'));
        await tester.pumpAndSettle();
        expect(find.text('Added to cart'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        unawaited(changes.close());
      }
    },
  );
}

Widget _homeWithBanners(AppData data, {bool reduceMotion = false}) =>
    ProviderScope(
      overrides: [
        appDataProvider.overrideWith((ref) async => data),
        dataRepositoryProvider.overrideWith((ref) => _FakeDataRepository(data)),
        connectivityProvider.overrideWith(
          (ref) => Stream.value(NetworkStatus.online),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: const HomeScreen(),
          ),
        ),
      ),
    );

double _bannerPage(WidgetTester tester) =>
    tester.widget<PageView>(find.byType(PageView)).controller!.page!;

AppData _dataWithBanners(int count) => AppData(
  member: _sampleData.member,
  products: const [],
  sections: const [],
  banners: List.generate(
    count,
    (index) => PromoBanner(
      title: 'Banner ${index + 1}',
      subtitle: 'Shop ${index + 1}',
      image: 'banner.svg',
    ),
  ),
  shops: const [],
  challenges: const [],
);

Widget _scaledScreen(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: const TextScaler.linear(1.3),
      disableAnimations: true,
    ),
    child: child,
  ),
);

void _disableMotion(WidgetTester tester) {
  tester.view.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(
    tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue,
  );
}

class _FakeDataRepository implements HomeRepository {
  _FakeDataRepository(this.data, {Map<String, int>? failedSections})
    : _failedSections = failedSections ?? {};
  final AppData data;
  int refreshes = 0;
  bool failNextRefresh = false;
  Completer<void>? refreshGate;
  final Map<String, int> _failedSections;
  final Map<String, int> sectionLoads = {};

  @override
  Future<Result<AppData>> load() async => Success(data);

  @override
  Future<Result<AppData>> refresh() async {
    refreshes++;
    await refreshGate?.future;
    if (failNextRefresh) {
      failNextRefresh = false;
      return const Error(StorageFailure('Temporary refresh failure'));
    }
    return Success(data);
  }

  @override
  Future<Result<List<Product>>> loadSectionProducts(String sectionId) async {
    sectionLoads.update(sectionId, (count) => count + 1, ifAbsent: () => 1);
    final remainingFailures = _failedSections[sectionId] ?? 0;
    if (remainingFailures > 0) {
      _failedSections[sectionId] = remainingFailures - 1;
      return const Error(StorageFailure('Temporary section read failure'));
    }
    final section = data.sections
        .where((item) => item.id == sectionId)
        .firstOrNull;
    if (section == null) return const Error(StorageFailure('Missing section'));
    return Success(
      section.productIds.map(data.product).whereType<Product>().toList(),
    );
  }
}

final _sampleData = AppData(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  products: const [
    Product(
      id: 'coconut',
      code: 'JD022123',
      name: 'Coconut Donut',
      priceMmk: 3200,
      isNew: true,
      image: 'coconut.svg',
      description: 'Soft coconut donut.',
    ),
  ],
  sections: [
    HomeSection(
      id: 'seasonal',
      title: 'Seasonal specials',
      productIds: ['coconut'],
    ),
    HomeSection(id: 'popular', title: 'Popular', productIds: ['coconut']),
    HomeSection(
      id: 'order-again',
      title: 'Order again',
      productIds: ['coconut'],
    ),
  ],
  banners: const [
    PromoBanner(title: 'New shop', subtitle: 'New shop', image: 'banner.svg'),
  ],
  shops: const [
    'Central Boulevard',
    'Junction City',
    'Myanmar Plaza',
    'Sanchaung',
  ],
  challenges: const [],
);
