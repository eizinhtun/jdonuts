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

    await tester.tap(find.text('Select date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);

    await tester.tap(find.text('LET’S EXPLORE'));
    await tester.pumpAndSettle();
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('You’re offline — showing saved items'), findsOneWidget);

    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    expect(find.text('JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect((await sessionStore.read())?.phone, '959254135592');
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
