import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/rewards/domain/rewards_repository.dart';
import 'package:jdonuts/features/rewards/presentation/rewards_screen.dart';
import 'package:jdonuts/features/rewards/presentation/widgets/points_ring.dart';
import 'package:jdonuts/features/rewards/presentation/widgets/points_ring_painter.dart';
import 'package:jdonuts/features/rewards/presentation/widgets/challenge_artwork.dart';
import 'package:jdonuts/features/rewards/presentation/widgets/challenge_card.dart';
import 'package:jdonuts/features/rewards/presentation/widgets/tier_ladder.dart';
import 'package:jdonuts/l10n/app_localizations.dart';

void main() {
  testWidgets('Rewards title and badge are in the app bar', (tester) async {
    await tester.pumpWidget(_rewardsApp(textScale: 1));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('J’ Donuts Rewards'),
      ),
      findsOneWidget,
    );
    expect(find.text('Rewards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pink backing extends through the bottom safe area', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(_rewardsApp(textScale: 1));
    await tester.pumpAndSettle();

    final pinkBacking = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.color == AppColors.pink &&
          widget.padding == const EdgeInsets.only(left: 22),
    );
    final cyanPanel = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color == AppColors.cyan,
    );

    expect(tester.getSize(pinkBacking).height, 106);
    expect(tester.getSize(cyanPanel).height, 72);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rewards navigation fits at the label breakpoint', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(380, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_rewardsApp(textScale: 1.1));
    await tester.pumpAndSettle();

    expect(find.text('Reward'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    final compactError = tester.takeException();
    expect(compactError, isNull, reason: '$compactError');

    await tester.tap(find.text('Gift'));
    await tester.pumpAndSettle();
    expect(find.text('Gift a treat to a friend'), findsWidgets);
    final reducedMotionError = tester.takeException();
    expect(reducedMotionError, isNull, reason: '$reducedMotionError');
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

  testWidgets('points ring and count animate to the persisted member values', (
    tester,
  ) async {
    await tester.pumpWidget(
      _rewardsApp(textScale: 1, disableAnimations: false),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(PointsRing), findsOneWidget);
    expect(_displayedPoints(tester), 0);
    expect(_pointsRingProgress(tester), 0);
    expect(_tierProgress(tester), 0);

    await tester.pump(const Duration(milliseconds: 360));
    final middlePoints = _displayedPoints(tester);
    final middleSweep = _pointsRingProgress(tester);
    final middleTierProgress = _tierProgress(tester);
    expect(middlePoints, greaterThan(0));
    expect(middlePoints, lessThan(680000));
    expect(middleSweep, greaterThan(0));
    expect(middleSweep, lessThan(1));
    expect(middleTierProgress, greaterThan(0));
    expect(middleTierProgress, lessThan(1));

    await tester.pump(const Duration(milliseconds: 400));
    expect(_displayedPoints(tester), 680000);
    expect(_pointsRingProgress(tester), closeTo(680000 / 680500, .00001));
    expect(_tierProgress(tester), closeTo(680000 / 680500, .00001));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('challenge images are bundled and render without internet', (
    tester,
  ) async {
    await tester.pumpWidget(_rewardsApp(textScale: 1));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsAtLeastNWidgets(2));
    expect(find.byIcon(Icons.donut_large), findsNothing);
    expect(find.byIcon(Icons.local_cafe_outlined), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('donut quarter artwork fills progressively to completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: ChallengeArtwork(kind: 'donut', progress: .25),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ClipPath), findsNothing);
    await tester.pump(const Duration(milliseconds: 260));
    expect(find.byType(ClipPath), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: ChallengeArtwork(kind: 'donut', progress: 1),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ClipPath), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed challenge cue plays once and settles', (tester) async {
    await tester.pumpWidget(
      _rewardsApp(textScale: 1, disableAnimations: false),
    );
    await tester.pump(const Duration(milliseconds: 900));

    final cue = tester.widget<ScaleTransition>(
      find.descendant(
        of: find.byType(ChallengeCard).first,
        matching: find.byType(ScaleTransition),
      ),
    );
    expect(cue.scale.value, closeTo(1, .001));

    await tester.pump(const Duration(seconds: 2));
    expect(cue.scale.value, closeTo(1, .001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty challenge data has an explicit empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _rewardsApp(textScale: 1, snapshot: _snapshot(challenges: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('No challenges available yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rewards exposes loading feedback before local data resolves', (
    tester,
  ) async {
    final result = Completer<RewardsSnapshot>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [rewardsDataProvider.overrideWith((ref) => result.future)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const RewardsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    result.complete(_snapshot(challenges: [_sampleData.challenges[1]]));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('680,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the persisted current tier is highlighted in the ladder', (
    tester,
  ) async {
    final member = Member(
      id: _sampleData.member.id,
      name: _sampleData.member.name,
      tier: 'Gold',
      points: _sampleData.member.points,
      pointsToGold: _sampleData.member.pointsToGold,
      notifications: _sampleData.member.notifications,
    );
    await tester.pumpWidget(
      _rewardsApp(
        textScale: 1,
        snapshot: RewardsSnapshot(
          member: member,
          challenges: _sampleData.challenges,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tier completed'), findsOneWidget);
    expect(find.text('You’re here now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid tab changes settle on the selected content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _rewardsApp(textScale: 1, disableAnimations: false),
    );
    await tester.pump(const Duration(milliseconds: 80));

    await tester.tap(find.text('Gift'));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.text('Eat more earn more'));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.tap(find.text('Gift'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Gift a treat to a friend'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Earn gives feedback without claiming or changing the challenge',
    (tester) async {
      await tester.pumpWidget(_rewardsApp(textScale: 1));
      await tester.pumpAndSettle();

      final buttons = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(buttons.at(0)).onPressed, isNotNull);
      expect(tester.widget<FilledButton>(buttons.at(1)).onPressed, isNull);
      tester.widget<FilledButton>(buttons.first).onPressed!();
      await tester.pump();

      expect(find.text('This section is coming soon.'), findsOneWidget);
      expect(find.text('EARNED'), findsNothing);
      expect(tester.widget<FilledButton>(buttons.first).onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Rewards retry is recoverable and ignores duplicate taps', (
    tester,
  ) async {
    var shouldFail = true;
    final retrySnapshot = _snapshot(challenges: [_sampleData.challenges[1]]);
    final repository = _FakeRewardsRepository(
      retrySnapshot,
      onRefresh: () {
        shouldFail = false;
      },
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rewardsDataProvider.overrideWith((ref) async {
            if (shouldFail) throw StateError('temporary read failure');
            return retrySnapshot;
          }),
          rewardsRepositoryProvider.overrideWith((ref) => repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RewardsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Rewards are unavailable'), findsOneWidget);

    final retry = tester.widget<TextButton>(find.byType(TextButton));
    retry.onPressed!();
    retry.onPressed!();
    await tester.pumpAndSettle();

    expect(repository.refreshes, 1);
    expect(find.text('680,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _rewardsApp({
  required double textScale,
  bool disableAnimations = true,
  RewardsSnapshot? snapshot,
}) => ProviderScope(
  overrides: [
    rewardsDataProvider.overrideWith((ref) async => snapshot ?? _snapshot()),
  ],
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

int _displayedPoints(WidgetTester tester) {
  final values = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(PointsRing),
          matching: find.byType(Text),
        ),
      )
      .toList();
  return int.parse(values.last.data!.replaceAll(',', ''));
}

double _pointsRingProgress(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(PointsRing),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((widget) => widget.painter)
    .whereType<PointsRingPainter>()
    .single
    .progress;

double _tierProgress(WidgetTester tester) => tester
    .widgetList<FractionallySizedBox>(
      find.descendant(
        of: find.byType(TierLadder),
        matching: find.byType(FractionallySizedBox),
      ),
    )
    .first
    .heightFactor!;

RewardsSnapshot _snapshot({List<Challenge>? challenges}) => RewardsSnapshot(
  member: _sampleData.member,
  challenges: challenges ?? _sampleData.challenges,
);

class _FakeRewardsRepository implements RewardsRepository {
  _FakeRewardsRepository(this.snapshot, {required this.onRefresh});

  final RewardsSnapshot snapshot;
  final VoidCallback onRefresh;
  int refreshes = 0;

  @override
  Future<Result<RewardsSnapshot>> load() async => Success(snapshot);

  @override
  Future<Result<RewardsSnapshot>> refresh() async {
    refreshes++;
    onRefresh();
    return Success(snapshot);
  }
}
