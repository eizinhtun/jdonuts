import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/home/presentation/widgets/home_skeleton.dart';

void main() {
  testWidgets('Home skeleton shimmer runs and stops for Reduce Motion', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeSkeleton()));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue();
  });

  testWidgets('Home skeleton shimmer pauses and resumes with app lifecycle', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeSkeleton()));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
