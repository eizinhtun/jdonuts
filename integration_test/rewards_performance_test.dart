import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/home/presentation/widgets/app_bottom_nav.dart';
import 'package:jdonuts/features/rewards/domain/rewards_repository.dart';
import 'package:jdonuts/features/rewards/presentation/rewards_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profiles Rewards tabs and Home navigation motion', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/rewards',
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [rewardsDataProvider.overrideWith((ref) async => _snapshot)],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await binding.watchPerformance(() async {
      for (var cycle = 0; cycle < 2; cycle++) {
        await tester.tap(find.text('Gift'));
        await tester.pump(const Duration(milliseconds: 220));
        await tester.tap(find.text('Eat more earn more'));
        await tester.pump(const Duration(milliseconds: 220));
        await tester.tap(find.byIcon(Icons.home_outlined).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 550));
        await tester.tap(find.byIcon(Icons.monetization_on_outlined).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 550));
      }
    }, reportKey: 'rewards_motion_profile');

    expect(find.text('J’ Donuts Rewards'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}

final _snapshot = RewardsSnapshot(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  challenges: const [
    Challenge(
      id: 'donut-progress',
      title: 'Eat 4 Coco donuts',
      progress: 1,
      target: 4,
      points: 100,
      kind: 'donut',
    ),
    Challenge(
      id: 'coffee-progress',
      title: 'Enjoy coffee moments',
      progress: 9,
      target: 12,
      points: 200,
      kind: 'coffee',
    ),
  ],
);
