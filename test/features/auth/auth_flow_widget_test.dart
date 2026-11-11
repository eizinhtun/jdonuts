import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
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
    expect(tester.getSize(fields.first), const Size(48, 64));
    expect(
      tester.widget<TextField>(fields.first).keyboardType,
      TextInputType.number,
    );
    await tester.enterText(fields.first, '1');
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isTrue);
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
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(boxes.map((field) => field.controller!.text).join(), '1234');
    expect(boxes[3].focusNode!.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration shows name and calendar validation inline', (
    tester,
  ) async {
    _disableMotion(tester);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 892);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = LocalAuthRepository(
      delay: (_) async {},
      registered: {},
      sessionStore: MemoryAuthSessionStore(),
    );
    await tester.pumpWidget(
      _testApp(repository, clock: () => DateTime(2026, 11, 11)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'May3');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Use up to 50 letters and spaces.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'May');
    await tester.enterText(find.byType(TextField).at(1), 'Aung2');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Use up to 50 letters and spaces.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    tester.testTextInput.hide();
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == 'Month',
      ),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).at(0), 'April');
    await tester.enterText(find.byType(TextField).at(1), '31');
    await tester.enterText(find.byType(TextField).at(2), '1980');
    tester.testTextInput.hide();
    await tester.pump();
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Choose a real calendar date.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '11');
    await tester.enterText(find.byType(TextField).at(2), '2015');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('You must be at least 13 years old.'), findsOneWidget);
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
    await tester.enterText(find.byType(TextField).at(1), 'Aung');
    await tester.pump();
    await tester.ensureVisible(find.byType(PrimaryButton));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('What’s your date of birth?'), findsOneWidget);
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
    expect(find.text('VERIFY'), findsNothing);
    expect(
      find.text('We’ve sent 6 digit OTP to +959254135592'),
      findsOneWidget,
    );
  });

  testWidgets('failed phone request stays on the form and can be retried', (
    tester,
  ) async {
    _disableMotion(tester);
    var failRequest = true;
    final repository = LocalAuthRepository(
      delay: (_) async {
        if (failRequest) throw StateError('temporary request failure');
      },
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

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Enter your phone number'), findsOneWidget);
    expect(find.text('Verify your number'), findsNothing);

    failRequest = false;
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Verify your number'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'session write failure is recoverable and is not an OTP failure',
    (tester) async {
      _disableMotion(tester);
      final sessions = _ToggleFailureSessionStore()..failWrite = true;
      final repository = LocalAuthRepository(
        delay: (_) async {},
        registered: {'95987654321'},
        sessionStore: sessions,
      );
      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Already have an account? Log In'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '987654321');
      await tester.pump();
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();

      await tester.tap(find.text('VERIFY'));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('That code is incorrect.'), findsNothing);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .map((field) => field.controller!.text)
            .join(),
        '123456',
      );
      expect(
        (await repository.hasSession()).fold((value) => value, (_) => true),
        isFalse,
      );

      sessions.failWrite = false;
      await tester.tap(find.text('VERIFY'));
      await tester.pumpAndSettle();
      expect(find.text('Seasonal specials'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      sessions.failClear = true;
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Settings'), findsOneWidget);

      sessions.failClear = false;
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('LET’S GET STARTED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('third wrong code locks entry until the five-minute resend', (
    tester,
  ) async {
    _disableMotion(tester);
    var now = DateTime(2026, 2, 1, 12);
    Completer<void>? resendGate;
    final repository = _CountingAuthRepository((_) async {
      if (resendGate case final gate?) await gate.future;
    });
    await tester.pumpWidget(_testApp(repository, clock: () => now));
    await tester.pumpAndSettle();
    await tester.tap(find.text('LET’S GET STARTED'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(repository.otpRequests, 1);
    expect(find.text('VERIFY'), findsNothing);

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
    expect(find.text('Resend code'), findsNothing);

    now = now.add(const Duration(minutes: 5));
    await tester.pump(const Duration(minutes: 5));
    await tester.pump();
    expect(find.text('Resend code'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend code'))
          .onPressed,
      isNotNull,
    );
    resendGate = Completer<void>();
    await tester.tap(find.text('Resend code'));
    await tester.pump();
    await tester.tap(find.text('Resend code'));
    await tester.pump();
    expect(repository.otpRequests, 2);
    resendGate.complete();
    await tester.pumpAndSettle();
    expect(
      find.text('Too many attempts. Resend the code when the timer ends.'),
      findsNothing,
    );
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .every(
            (field) => field.enabled == true && field.controller!.text.isEmpty,
          ),
      isTrue,
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

class _ToggleFailureSessionStore implements AuthSessionStore {
  AuthUser? user;
  bool failWrite = false;
  bool failClear = false;

  @override
  Future<AuthUser?> read() async => user;

  @override
  Future<void> write(AuthUser value) async {
    if (failWrite) throw StateError('session storage unavailable');
    user = value;
  }

  @override
  Future<void> clear() async {
    if (failClear) throw StateError('session clear unavailable');
    user = null;
  }
}

void _disableMotion(WidgetTester tester) {
  tester.view.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(
    tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue,
  );
}
