import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonuts/main.dart';

void main() {
  testWidgets('onboarding offers registration and returning login', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: JDonutsApp()));
    await tester.pumpAndSettle();
    expect(find.text('LET’S GET STARTED'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);
  });
}
