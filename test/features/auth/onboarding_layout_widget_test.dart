import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/features/auth/presentation/entry_screens.dart';
import 'package:jdonuts/features/auth/presentation/onboarding_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('onboarding fits a narrow phone at text scale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Round food for every mood'), findsOneWidget);
    expect(find.text('LET’S GET STARTED'), findsOneWidget);
    expect(find.textContaining('By continuing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Welcome collage fits a narrow phone at text scale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const WelcomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);
    expect(find.text('LET’S EXPLORE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
