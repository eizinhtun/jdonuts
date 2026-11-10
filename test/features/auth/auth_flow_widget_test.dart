import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';
import 'package:jdonuts/main.dart';

void main() {
  testWidgets('a pending phone submission cannot be started twice', (
    tester,
  ) async {
    final requestGate = Completer<void>();
    final repository = _DelayedOtpRepository(requestGate.future);
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.otpRequests, 1);

    requestGate.complete();
    await tester.pumpAndSettle();
    expect(find.text('VERIFY'), findsOneWidget);
  });

  testWidgets('third wrong code locks entry until the five-minute resend', (
    tester,
  ) async {
    var now = DateTime(2026, 2, 1, 12);
    final repository = LocalAuthRepository(
      delay: (_) async {},
      registered: {},
      sessionStore: MemoryAuthSessionStore(),
    );
    await tester.pumpWidget(_testApp(repository, clock: () => now));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('VERIFY'), findsOneWidget);

    for (var attempt = 0; attempt < 3; attempt++) {
      await tester.enterText(find.byType(TextField).first, '000000');
      await tester.pump();
      await tester.tap(find.text('VERIFY'));
      await tester.pumpAndSettle();
    }
    expect(
      find.text('Too many attempts. Resend the code when the timer ends.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'))
          .onPressed,
      isNull,
    );

    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(minutes: 5));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();
    expect(
      find.text('Too many attempts. Resend the code when the timer ends.'),
      findsNothing,
    );
  });
}

Widget _testApp(AuthRepository repository, {DateTime Function()? clock}) =>
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          final database = AppDatabase.forTesting(NativeDatabase.memory());
          ref.onDispose(database.close);
          return database;
        }),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        authRepositoryProvider.overrideWith((ref) => repository),
        if (clock != null) clockProvider.overrideWith((ref) => clock),
      ],
      child: const JDonutsApp(),
    );

class _DelayedOtpRepository extends LocalAuthRepository {
  _DelayedOtpRepository(Future<void> requestGate)
    : super(
        registered: {},
        sessionStore: MemoryAuthSessionStore(),
        delay: (_) => requestGate,
      );

  int otpRequests = 0;

  @override
  Future<Result<bool>> requestOtp(String phone) {
    otpRequests++;
    return super.requestOtp(phone);
  }
}
