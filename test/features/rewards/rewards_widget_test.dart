import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/rewards/presentation/rewards_screen.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('Rewards fits a small portrait viewport at 1.3 text scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 667);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_rewardsApp(textScale: 1.3));
    await tester.pumpAndSettle();

    expect(find.text('680,000'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(find.text('Eat more earn more'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Gift'));
    await tester.pumpAndSettle();
    expect(find.text('Gift a treat to a friend'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Reduce Motion renders completed rewards without looping', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_rewardsApp(textScale: 1, disableAnimations: true));
    await tester.pump();
    expect(find.text('680,000'), findsOneWidget);
    expect(find.text('EARN'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Widget _rewardsApp({
  required double textScale,
  bool disableAnimations = true,
}) => ProviderScope(
  overrides: [appDataProvider.overrideWith((ref) async => _sampleData)],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: const RewardsScreen(),
      ),
    ),
  ),
);

final _sampleData = AppData(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  products: const [],
  sections: const [],
  banners: const [],
  shops: const [],
  challenges: const [
    Challenge(
      id: 'donut',
      title: 'Eat 4 Coco donuts',
      progress: 4,
      target: 4,
      points: 100,
      kind: 'donut',
    ),
    Challenge(
      id: 'coffee',
      title: 'Enjoy coffee moments',
      progress: 9,
      target: 12,
      points: 200,
      kind: 'coffee',
    ),
  ],
);
