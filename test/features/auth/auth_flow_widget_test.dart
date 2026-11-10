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
  testWidgets('each authentication request ignores a second submit tap', (
    tester,
  ) async {
    _disableMotion(tester);
    Completer<void>? requestGate;
    final repository = _CountingAuthRepository((_) async {
      final gate = requestGate;
      if (gate != null) await gate.future;
    });
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();

    requestGate = Completer<void>();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.otpRequests, 1);
    requestGate.complete();
    requestGate = null;
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    requestGate = Completer<void>();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.otpVerifications, 1);
    requestGate.complete();
    requestGate = null;
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'May');
    await tester.pump();
    requestGate = Completer<void>();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.profileSaves, 1);
    requestGate.complete();
    requestGate = null;
    await tester.pumpAndSettle();

    final birthFields = find.byType(TextField);
    await tester.enterText(birthFields.at(0), 'May');
    await tester.enterText(birthFields.at(1), '1');
    await tester.enterText(birthFields.at(2), '1980');
    await tester.pump();
    requestGate = Completer<void>();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.registrations, 1);
    requestGate.complete();
    requestGate = null;
    await tester.pumpAndSettle();

    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OTP paste distributes digits and backspace moves left', (
    tester,
  ) async {
    _disableMotion(tester);
    final repository = LocalAuthRepository(
      delay: (_) async {},
      registered: {},
      sessionStore: MemoryAuthSessionStore(),
    );
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '123456');
    await tester.pump();
    final boxes = tester.widgetList<TextField>(fields).toList();
    expect(boxes.map((field) => field.controller!.text).join(), '123456');
    expect(boxes.first.autofillHints, contains(AutofillHints.oneTimeCode));
    expect(boxes.last.focusNode!.hasFocus, isTrue);

    await tester.enterText(fields.last, '');
    await tester.pump();
    expect(boxes.map((field) => field.controller!.text).join(), '12345');
    expect(boxes[4].focusNode!.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration keeps values on a compact screen at 1.3 scale', (
    tester,
  ) async {
    _disableMotion(tester);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 667);
    tester.view.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.platformDispatcher.clearTextScaleFactorTestValue);

    final repository = LocalAuthRepository(
      delay: (_) async {},
      registered: {},
      sessionStore: MemoryAuthSessionStore(),
    );
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('What’s your name?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'May');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Enter your phone number'), findsOneWidget);
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('What’s your name?'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      'May',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a pending phone submission cannot be started twice', (
    tester,
  ) async {
    _disableMotion(tester);
    final requestGate = Completer<void>();
    final repository = _DelayedOtpRepository(requestGate.future);
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '0 925-413-5592');
    await tester.pump();

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();
    expect(repository.otpRequests, 1);

    requestGate.complete();
    await tester.pumpAndSettle();
    expect(find.text('VERIFY'), findsOneWidget);
    expect(
      find.text('Enter the 6-digit code sent to +95 9254135592'),
      findsOneWidget,
    );
  });

  testWidgets('third wrong code locks entry until the five-minute resend', (
    tester,
  ) async {
    _disableMotion(tester);
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
          .widgetList<TextField>(find.byType(TextField))
          .every((field) => field.enabled == false),
      isTrue,
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

class _CountingAuthRepository extends LocalAuthRepository {
  _CountingAuthRepository(Future<void> Function(Duration) delay)
    : super(
        registered: {},
        sessionStore: MemoryAuthSessionStore(),
        delay: delay,
      );

  int otpRequests = 0;
  int otpVerifications = 0;
  int profileSaves = 0;
  int registrations = 0;

  @override
  Future<Result<bool>> requestOtp(String phone) {
    otpRequests++;
    return super.requestOtp(phone);
  }

  @override
  Future<Result<bool>> verifyOtp(String phone, String code) {
    otpVerifications++;
    return super.verifyOtp(phone, code);
  }

  @override
  Future<Result<bool>> saveRegistrationProfile(AuthUser user) {
    profileSaves++;
    return super.saveRegistrationProfile(user);
  }

  @override
  Future<Result<AuthUser>> register(AuthUser user) {
    registrations++;
    return super.register(user);
  }
}

void _disableMotion(WidgetTester tester) {
  tester.view.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(
    tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue,
  );
}
