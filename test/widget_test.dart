import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/storage/app_database.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/features/home/domain/models.dart';
import 'package:jdonuts/features/home/domain/home_repository.dart';
import 'package:jdonuts/features/auth/data/local_auth_repository.dart';
import 'package:jdonuts/features/auth/data/auth_session_store.dart';
import 'package:jdonuts/main.dart';

void main() {
  testWidgets('onboarding offers registration and returning login', (
    tester,
  ) async {
    _disableMotion(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    expect(find.text('LET’S GET STARTED'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);
  });

  testWidgets('a returning member logs in and can log out from Settings', (
    tester,
  ) async {
    _disableMotion(tester);
    await tester.pumpWidget(_testApp(registered: {'95987654321'}));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '987654321');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Verify your number'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    await tester.tap(find.text('VERIFY'));
    await tester.pumpAndSettle();
    expect(find.text('Seasonal specials'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('LET’S GET STARTED'), findsOneWidget);
  });

  testWidgets('unknown login number offers registration with its value kept', (
    tester,
  ) async {
    _disableMotion(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Already have an account? Log in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '9254135592');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(
      find.text('This number is new. Register to continue.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Register with this number'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '9254135592',
    );
  });

  testWidgets('phone error appears after an invalid number loses focus', (
    tester,
  ) async {
    _disableMotion(tester);
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
    _disableMotion(tester);
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
    expect(find.text('Verify your number'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Enter your phone number'), findsOneWidget);
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
    expect(find.text('What’s your date of birth?'), findsOneWidget);

    final birthFields = find.byType(TextField);
    await tester.enterText(birthFields.at(0), 'May');
    await tester.enterText(birthFields.at(1), '1');
    await tester.enterText(birthFields.at(2), '1980');
    await tester.pump();
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Welcome to the world of J’Donuts'), findsOneWidget);

    await tester.tap(find.text('LET’S EXPLORE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _pumpUntilFound(tester, find.text('Seasonal specials'));
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

void _disableMotion(WidgetTester tester) {
  tester.view.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(
    tester.view.platformDispatcher.clearAccessibilityFeaturesTestValue,
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 20 && finder.evaluate().isEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _testApp({Set<String> registered = const {}}) => ProviderScope(
  overrides: [
    appDatabaseProvider.overrideWith((ref) {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      ref.onDispose(database.close);
      return database;
    }),
    connectivityProvider.overrideWith((ref) => Stream.value(true)),
    appDataProvider.overrideWith((ref) async => _widgetData),
    dataRepositoryProvider.overrideWith((ref) => _WidgetDataRepository()),
    authRepositoryProvider.overrideWith(
      (ref) => LocalAuthRepository(
        delay: (_) async {},
        registered: registered,
        sessionStore: MemoryAuthSessionStore(),
      ),
    ),
  ],
  child: const JDonutsApp(),
);

final _widgetData = AppData(
  member: const Member(
    id: 'member-1',
    name: 'Hania',
    tier: 'Silver',
    points: 680000,
    pointsToGold: 500,
    notifications: 2,
  ),
  products: const [
    Product(
      id: 'coconut',
      code: 'JD022123',
      name: 'Coconut Donut',
      priceMmk: 3200,
      isNew: true,
      image: 'coconut.svg',
      description: 'Soft coconut donut.',
    ),
  ],
  sections: [
    HomeSection(
      id: 'seasonal',
      title: 'Seasonal specials',
      productIds: ['coconut'],
    ),
    HomeSection(id: 'popular', title: 'Popular', productIds: ['coconut']),
    HomeSection(
      id: 'order-again',
      title: 'Order again',
      productIds: ['coconut'],
    ),
  ],
  banners: const [
    PromoBanner(title: 'New shop', subtitle: 'New shop', image: 'banner.svg'),
  ],
  shops: const ['Central', 'Junction City', 'Myanmar Plaza', 'Sanchaung'],
  challenges: const [],
);

class _WidgetDataRepository implements HomeRepository {
  @override
  Future<Result<AppData>> load() async => Success(_widgetData);

  @override
  Future<Result<AppData>> refresh() async => Success(_widgetData);

  @override
  Future<Result<List<Product>>> loadSectionProducts(String sectionId) async {
    final section = _widgetData.sections
        .where((item) => item.id == sectionId)
        .firstOrNull;
    if (section == null) return const Error(StorageFailure('Missing section'));
    return Success(
      section.productIds.map(_widgetData.product).whereType<Product>().toList(),
    );
  }
}
