import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/home/presentation/widgets/app_bottom_nav.dart';
import 'package:jdonuts/features/rewards/domain/rewards_repository.dart';
import 'package:jdonuts/features/rewards/presentation/rewards_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'Home and Rewards navigation survives repeated active-pill flights',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(
              body: Center(child: Text('Home destination')),
              bottomNavigationBar: AppBottomNav(selected: 0, homeStyle: true),
            ),
          ),
          GoRoute(path: '/rewards', builder: (_, _) => const RewardsScreen()),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rewardsDataProvider.overrideWith(
              (ref) async => RewardsSnapshot(
                member: const Member(
                  id: 'member',
                  name: 'Hania',
                  tier: 'Silver',
                  points: 680000,
                  pointsToGold: 500,
                  notifications: 2,
                ),
                challenges: const [],
              ),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: false),
              child: child!,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.workspace_premium_outlined).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('J’ Donuts Rewards'), findsOneWidget);

      for (var index = 0; index < 2; index++) {
        await tester.tap(find.byIcon(Icons.home_outlined).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('Home destination'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.workspace_premium_outlined).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('J’ Donuts Rewards'), findsOneWidget);
      }

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
