import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';

void main() {
  testWidgets('entrance moves into place once and settles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: const AnimatedEntrance(child: Text('Entrance')),
        ),
      ),
    );
    await tester.pump();

    final initialTransform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(AnimatedEntrance),
        matching: find.byType(Transform),
      ),
    );
    expect(
      initialTransform.transform.getTranslation().y,
      Motion.entranceDistance,
    );

    await tester.pumpAndSettle();
    final finalTransform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(AnimatedEntrance),
        matching: find.byType(Transform),
      ),
    );
    expect(finalTransform.transform.getTranslation().y, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion shows entrance at its final state immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const AnimatedEntrance(child: Text('Entrance')),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AnimatedEntrance),
        matching: find.byType(Opacity),
      ),
    );
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(AnimatedEntrance),
        matching: find.byType(Transform),
      ),
    );
    expect(opacity.opacity, 1);
    expect(transform.transform.getTranslation().y, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('button press scales and loading preserves its height', (
    tester,
  ) async {
    var loading = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 240,
              child: PrimaryButton(
                label: 'Continue',
                loading: loading,
                onPressed: () => setState(() => loading = !loading),
              ),
            ),
          ),
        ),
      ),
    );
    final height = tester.getSize(find.byType(PrimaryButton)).height;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PrimaryButton)),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      Motion.buttonPressScale,
    );
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(find.byType(PrimaryButton)).height, height);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion disables button press scaling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(
            child: PrimaryButton(label: 'Continue', onPressed: () {}),
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PrimaryButton)),
    );
    await tester.pump();
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(PrimaryButton),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      1,
    );
    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
