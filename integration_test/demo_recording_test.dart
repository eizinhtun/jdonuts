import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/network/network_reachability.dart';
import 'package:jdonuts/features/auth/data/auth_account_store.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('records the local registration and rewards walkthrough', (
    tester,
  ) async {
    final sessionStore = SecureAuthSessionStore();
    await sessionStore.clear();
    await tester.pumpWidget(_recordingApp(sessionStore));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.enterText(find.byType(TextField).first, '9254135593');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), '1');
    await tester.enterText(find.byType(TextField).at(2), '1980');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S EXPLORE'));
    await _waitFor(tester, find.text('Seasonal specials'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 10));

    await _waitFor(tester, find.text('Coconut Donut'));
    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await _waitFor(tester, find.text('JD022123'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 8));
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));
    await tester.tap(find.textContaining('ADD TO CART').first);
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.arrow_back));
    await _waitFor(tester, find.text('Seasonal specials'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rewards').last);
    await _waitFor(tester, find.text('J’ Donuts Rewards'));
    await _advance(tester, const Duration(milliseconds: 600));
    await _hold(tester, const Duration(seconds: 10));
    await tester.tap(find.text('Profile').last);
    await _waitFor(tester, find.text('Settings'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));
    await tester.tap(find.text('Log out'));
    await _waitFor(tester, find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));

    await tester.tap(find.textContaining('Log in').last);
    await _waitFor(tester, find.text('Log in'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));
    await tester.enterText(find.byType(TextField).first, '9254135593');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await _waitFor(tester, find.text('VERIFY'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 3));
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();
    await tester.tap(find.text('VERIFY'));
    await _waitFor(tester, find.text('Seasonal specials'));
    await tester.pumpAndSettle();
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);
    await _hold(tester, const Duration(seconds: 7));
    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await _waitFor(tester, find.text('JD022123'));
    await tester.pumpAndSettle();
    await _hold(tester, const Duration(seconds: 7));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await _waitFor(tester, find.text('Seasonal specials'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rewards').last);
    await _waitFor(tester, find.text('J’ Donuts Rewards'));
    await _advance(tester, const Duration(milliseconds: 600));
    await _hold(tester, const Duration(seconds: 10));

    expect(tester.takeException(), isNull);
  });
}

Widget _recordingApp(SecureAuthSessionStore sessionStore) => ProviderScope(
  overrides: [
    connectivityProvider.overrideWith(
      (ref) => Stream.value(NetworkStatus.offline),
    ),
    authRepositoryProvider.overrideWith(
      (ref) => LocalAuthRepository(
        sessionStore: sessionStore,
        accountStore: DriftAuthAccountStore(ref.watch(appDatabaseProvider)),
      ),
    ),
  ],
  child: const JDonutsApp(),
);

Future<void> _hold(WidgetTester tester, Duration duration) async {
  await tester.runAsync(() => Future<void>.delayed(duration));
  await tester.pump();
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 100 && finder.evaluate().isEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _advance(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 16);
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(frame);
    elapsed += frame;
  }
}
