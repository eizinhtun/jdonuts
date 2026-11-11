import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/features/product/presentation/product_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('a missing bundled image shows the image fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 120,
          height: 120,
          child: SeedImage(assetName: 'missing-seed-image.png'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a missing product offers a route back to Home', (tester) async {
    final router = GoRouter(
      initialLocation: '/product/missing-id',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home destination')),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) => ProductScreen(
            productId: state.pathParameters['id']!,
            heroTag: 'missing-product',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productProvider.overrideWith((ref, productId) async => null),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Product not found'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home destination'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
