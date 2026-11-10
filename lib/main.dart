import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';

import 'core/theme/tokens.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_flow.dart';
import 'features/home/data/local_data_repository.dart';
import 'features/home/domain/models.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/product/presentation/product_screen.dart';
import 'features/rewards/presentation/rewards_screen.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => LocalAuthRepository(),
);
final dataRepositoryProvider = Provider<LocalDataRepository>(
  (ref) => SeedDataRepository(),
);
final appDataProvider = FutureProvider<AppData>(
  (ref) => ref.watch(dataRepositoryProvider).load(),
);
final sessionProvider = FutureProvider<bool>(
  (ref) => ref.watch(authRepositoryProvider).hasSession(),
);
final authStateProvider = StateProvider<bool?>((ref) => null);

void main() => runApp(const ProviderScope(child: JDonutsApp()));

class JDonutsApp extends ConsumerWidget {
  const JDonutsApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final authenticated = ref.watch(authStateProvider);
    final router = GoRouter(
      initialLocation: '/onboarding',
      redirect: (context, state) {
        if (session.isLoading) return null;
        final isAuthed = authenticated ?? session.value ?? false;
        final inAuth =
            state.matchedLocation.startsWith('/auth') ||
            state.matchedLocation == '/onboarding';
        if (!isAuthed && !inAuth) return '/onboarding';
        if (isAuthed && inAuth) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth/:mode/:step',
          builder: (_, state) => AuthFlow(
            mode: state.pathParameters['mode']!,
            step: state.pathParameters['step']!,
          ),
        ),
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/rewards', builder: (_, _) => const RewardsScreen()),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) =>
              ProductScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    );
    return MaterialApp.router(
      title: 'J’Donuts',
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.palePink,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 10,
                    top: 25,
                    child: _donutTile('coconut.svg', -0.2, 90),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    child: _donutTile('strawberry.svg', 0.18, 110),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 0,
                    child: _donutTile('box.svg', 0.2, 100),
                  ),
                  Positioned(
                    right: 25,
                    bottom: 5,
                    child: _donutTile('coffee.svg', -0.1, 94),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Round food for every mood',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'LET’S GET STARTED',
              onPressed: () => context.go('/auth/register/phone'),
            ),
            const SizedBox(height: AppSpace.md),
            TextButton(
              onPressed: () => context.go('/auth/login/phone'),
              child: const Text('Already have an account? Log in'),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: ['Google', 'Apple', 'Facebook']
                  .map(
                    (s) => TextButton(
                      onPressed: () => _placeholder(context, s),
                      child: Text(s),
                    ),
                  )
                  .toList(),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: ['Terms of Use', 'Privacy Policy']
                  .map(
                    (s) => TextButton(
                      onPressed: () => _placeholder(context, s),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.palePink,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 330,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: const [
                  _WelcomeTile(
                    asset: 'coconut.svg',
                    color: Color(0xFFB6DDE9),
                    angle: -.14,
                  ),
                  _WelcomeTile(
                    asset: 'strawberry.svg',
                    color: Color(0xFFDBE9F7),
                    angle: .12,
                  ),
                  _WelcomeTile(
                    asset: 'box.svg',
                    color: Color(0xFFFFDCCE),
                    angle: .1,
                  ),
                  _WelcomeTile(
                    asset: 'coffee.svg',
                    color: Color(0xFFFFCE75),
                    angle: -.14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              'Welcome to the\nworld of J’donuts',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            PrimaryButton(
              label: 'LET’S EXPLORE',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Log out'),
      onTap: () async {
        await ref.read(authRepositoryProvider).logout();
        ref.read(authStateProvider.notifier).state = false;
        if (context.mounted) context.go('/onboarding');
      },
    ),
  );
}

class _WelcomeTile extends StatelessWidget {
  const _WelcomeTile({
    required this.asset,
    required this.color,
    required this.angle,
  });
  final String asset;
  final Color color;
  final double angle;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Transform.rotate(
        angle: angle,
        child: SizedBox(
          width: 90,
          height: 90,
          child: Image.asset('assets/images/$asset'),
        ),
      ),
    ),
  );
}

Widget _donutTile(String asset, double angle, double size) => Transform.rotate(
  angle: angle,
  child: SizedBox(
    width: size,
    height: size,
    child: Image.asset('assets/images/$asset'),
  ),
);
void _placeholder(BuildContext context, String feature) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not connected in this demo.')),
    );

String formatMmk(int value) {
  final digits = value.toString();
  final output = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) output.write(',');
    output.write(digits[i]);
  }
  return '$output MMK';
}

class PointsRingPainter extends CustomPainter {
  PointsRingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(
      center,
      radius - 15,
      Paint()
        ..color = const Color(0xFFEEF0F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant PointsRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
