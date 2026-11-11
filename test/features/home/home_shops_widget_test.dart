import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/features/home/presentation/widgets/home_shops.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('nearby shops fit a narrow viewport at 1.3 text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const Scaffold(
          backgroundColor: AppColors.canvas,
          body: SingleChildScrollView(
            child: HomeShops(shops: ['Mayangone J’Donut', 'Junction City']),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('There are 2 J’Donut shops near you. 😊'), findsOneWidget);
    expect(find.text('EXPLORE NOW'), findsOneWidget);
    expect(find.byType(SeedImage), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
