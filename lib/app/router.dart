import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_observer.dart';
import '../features/auth/presentation/auth_flow.dart';
import '../features/auth/presentation/entry_screens.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/product/presentation/product_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import 'providers.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authStateProvider, (_, _) => refresh.notify());
  ref.listen(sessionProvider, (_, _) => refresh.notify());

  final router = GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: refresh,
    observers: [appRouteObserver],
    redirect: (context, state) {
      final explicitAuthState = ref.read(authStateProvider);
      final session = ref.read(sessionProvider);
      if (session.isLoading && explicitAuthState == null) return null;

      final restoredSession = session.value?.fold<bool>(
        (hasSession) => hasSession,
        (_) => false,
      );
      final isAuthenticated = explicitAuthState ?? restoredSession ?? false;
      final location = state.matchedLocation;
      final isAuthLocation =
          location.startsWith('/auth') || location == '/onboarding';
      if (!isAuthenticated && !isAuthLocation) {
        return '/onboarding';
      }
      if (isAuthenticated && isAuthLocation) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
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
        builder: (_, state) => ProductScreen(
          productId: state.pathParameters['id']!,
          heroTag:
              state.extra as String? ?? 'product-${state.pathParameters['id']}',
        ),
      ),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refresh.dispose);
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
