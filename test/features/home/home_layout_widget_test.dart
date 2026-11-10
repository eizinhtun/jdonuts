import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/home/data/local_data_repository.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/home/presentation/home_screen.dart';
import 'package:jdonuts/features/product/presentation/product_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'offline Home reconnects and product fits a small portrait view',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 667);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final changes = StreamController<bool>();
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
        changes.add(false);
        await tester.pump();
        expect(
          find.text('You’re offline — showing saved items'),
          findsOneWidget,
        );

        changes.add(true);
        await tester.pumpAndSettle();
        expect(repository.refreshes, 1);

        await tester.ensureVisible(find.text('Coconut Donut').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Coconut Donut').first);
        await tester.pumpAndSettle();
        expect(find.text('JD022123'), findsOneWidget);
        expect(find.text('3,200 MMK'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        unawaited(changes.close());
      }
    },
  );
}

Widget _scaledScreen(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: const TextScaler.linear(1.3),
      disableAnimations: true,
    ),
    child: child,
  ),
);

class _FakeDataRepository implements LocalDataRepository {
  _FakeDataRepository(this.data);
  final AppData data;
  int refreshes = 0;

  @override
  Future<Result<AppData>> load() async => Success(data);

  @override
  Future<Result<AppData>> refresh() async {
    refreshes++;
    return Success(data);
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
