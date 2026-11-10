import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/main.dart';

void main() {
  testWidgets('onboarding offers registration and returning login', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    expect(find.text('LET’S GET STARTED'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);
  });

  testWidgets('phone error appears after an invalid number loses focus', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9123456');
    await tester.pump();
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    expect(find.text('Enter a valid Myanmar mobile number.'), findsOneWidget);
  });

  testWidgets('new user can register, reach Home, and open product detail', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('VERIFY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('What’s your name?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'May');
    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Verify number'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('What’s your phone number?'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.controller?.text ?? '')
          .join(),
      '123456',
    );
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      'May',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      'Aung',
    );

    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('When’s your birthday?'), findsOneWidget);

    await tester.tap(find.text('Select date of birth'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);

    await tester.tap(find.text('LET’S EXPLORE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Seasonal specials'), findsOneWidget);

    await tester.ensureVisible(find.text('Coconut Donut').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coconut Donut').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Coconut Donut'), findsWidgets);
    expect(find.text('3,200 MMK'), findsOneWidget);
  });
}

Widget _testApp() => ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWith((ref) {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      ref.onDispose(database.close);
      return database;
    }),
    connectivityProvider.overrideWith((ref) => Stream.value(true)),
    authRepositoryProvider.overrideWith(
      (ref) => LocalAuthRepository(
        delay: (_) async {},
        registered: {},
        sessionStore: MemoryAuthSessionStore(),
      ),
    ),
  ],
  child: const JDonutsApp(),
);
