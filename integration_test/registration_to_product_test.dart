import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register, Welcome, Home, and open Product detail', (
    tester,
  ) async {
    tester.view.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    final sessionStore = SecureAuthSessionStore();
    await sessionStore.clear();
    await tester.pumpWidget(_testApp(sessionStore));
    await tester.pumpAndSettle();

    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    expect(find.text('What’s your name?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '1980');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await _pumpUntilFound(
      tester,
      find.text('Welcome to the world of J’Donuts'),
    );
    if (find.text('Welcome to the world of J’Donuts').evaluate().isEmpty) {
      debugPrint(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? text.textSpan?.toPlainText())
            .join(' | '),
      );
    }
    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);

    await tester.tap(find.text('LET’S EXPLORE'));
    await _pumpUntilFound(tester, find.text('Seasonal specials'));
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);

    await _pumpUntilFound(tester, find.text('Coconut Donut'));
    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    expect(find.text('JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect((await sessionStore.read())?.phone, '959254135592');

    // Recreate the app/provider scope to exercise durable session restore.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_testApp(sessionStore));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Seasonal specials'));
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);
    await sessionStore.clear();
  });
}

Widget _testApp(SecureAuthSessionStore sessionStore) => ProviderScope(
  overrides: [
    connectivityProvider.overrideWith((ref) => Stream.value(false)),
    authRepositoryProvider.overrideWith(
      (ref) => LocalAuthRepository(
        delay: (_) async {},
        registered: {},
        sessionStore: sessionStore,
        accountStore: DriftAuthAccountStore(ref.watch(appDatabaseProvider)),
      ),
    ),
  ],
  child: const JDonutsApp(),
);

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 30 && finder.evaluate().isEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
