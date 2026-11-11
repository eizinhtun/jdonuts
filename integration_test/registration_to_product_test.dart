import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/network/network_reachability.dart';
import 'package:jdonuts/core/storage/app_database.dart';
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
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await sessionStore.clear();
    await tester.pumpWidget(_testApp(sessionStore, database));
    await tester.pumpAndSettle();

    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    _expectNoException(tester, 'Phone screen');
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await _hideKeyboardAndEnsureVisible(tester, find.text('CONTINUE'));
    _expectNoException(tester, 'Phone entry');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    _expectNoException(tester, 'OTP screen');

    await tester.enterText(find.byType(TextField).first, '123456');
    await _hideKeyboardAndEnsureVisible(tester, find.text('VERIFY'));
    _expectNoException(tester, 'OTP entry');
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    _expectNoException(tester, 'Name screen');
    expect(find.text('What’s your name?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    await _hideKeyboardAndEnsureVisible(tester, find.text('CONTINUE'));
    _expectNoException(tester, 'Name entry');
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    _expectNoException(tester, 'Date of birth screen');

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '1980');
    await _hideKeyboardAndEnsureVisible(tester, find.text('CONTINUE'));
    _expectNoException(tester, 'Date of birth entry');
    await tester.tap(find.text('CONTINUE'));
    await _pumpUntilFound(
      tester,
      find.text('Welcome to the world of J’Donuts'),
    );
    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);
    _expectNoException(tester, 'Welcome screen');

    await tester.tap(find.text('LET’S EXPLORE'));
    await _pumpUntilFound(tester, find.text('Seasonal specials'));
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('May Aung'), findsOneWidget);
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.workspace_premium_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('J’ Donuts Rewards'), findsOneWidget);
    expect(find.text('680,000'), findsOneWidget);
    expect(find.text('May Aung'), findsNothing);
    await tester.tap(find.byIcon(Icons.home_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('May Aung'), findsOneWidget);

    await _pumpUntilFound(tester, find.text('Coconut Donut'));
    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    expect(find.text('JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsNWidgets(2));
    expect(find.byType(Image), findsWidgets);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    expect(tester.takeException(), isNull);
    expect((await sessionStore.read())?.phone, '959254135592');

    // Recreate the app/provider scope to exercise durable session restore.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(_testApp(sessionStore, database));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('Seasonal specials'));
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('May Aung'), findsOneWidget);
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('LET’S GET STARTED'), findsOneWidget);

    await tester.tap(find.text('Already have an account? Log In'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await _hideKeyboardAndEnsureVisible(tester, find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await _hideKeyboardAndEnsureVisible(tester, find.text('VERIFY'));
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('May Aung'));
    expect(find.text('May Aung'), findsOneWidget);
    expect((await sessionStore.read())?.phone, '959254135592');
    await tester.tap(find.byIcon(Icons.workspace_premium_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('680,000'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await sessionStore.clear();
  });
}

Widget _testApp(SecureAuthSessionStore sessionStore, AppDatabase database) =>
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => database),
        connectivityProvider.overrideWith(
          (ref) => Stream.value(NetworkStatus.offline),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => LocalAuthRepository(
            delay: (_) async {},
            sessionStore: sessionStore,
            accountStore: DriftAuthAccountStore(database),
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

void _expectNoException(WidgetTester tester, String screen) {
  expect(tester.takeException(), isNull, reason: screen);
}

Future<void> _hideKeyboardAndEnsureVisible(
  WidgetTester tester,
  Finder target,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}
