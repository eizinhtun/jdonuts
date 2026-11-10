# J’Donuts Flutter Code Test

Offline-first mobile demo implementing onboarding/auth, Home, product detail and Rewards from the supplied code-test brief. Reference screenshots and the PDF remain outside the repository.

## Run

```sh
flutter pub get
flutter run
```

Demo OTP: `123456`. One returning test number is `+95 987654321` (normalizes to `95987654321`). Use any valid new Myanmar mobile number to register.

## Versions

Tested toolchain present at implementation start: Flutter 3.47.5 stable, Dart 3.13.4, Xcode 27.1, macOS arm64. Exact dependency versions are in `pubspec.lock` after successful `flutter pub get`.

## Architecture and folder map

- `lib/features/auth`, `home`, `product`, `rewards`: each separates domain/data/presentation.
- `lib/core`: Result/Failure, theme tokens, motion constants.
- `assets/data/seed.json`: bundled catalog, banners, sections, shops, challenge and shared member.
- `assets/images`: original hand-authored vector illustrations.

Riverpod is intended for application-wide dependency injection and async state so widgets do not create repositories. go_router owns the auth guard and `/product/:id`. Auth uses a repository interface and fake implementation; UI and validators are separated.

## Offline strategy

All product data and images are bundled and loaded from the asset bundle. The UI remains usable without network. Pull-to-refresh reloads the bundled source; this demo has no backend, so there is no remote refresh or true connectivity/reachability signal yet. SQLite/Drift, durable secure session storage and disk image cache require dependencies that could not be resolved in this environment. Auth data/session are currently in-memory; relaunch persistence is therefore a known gap.

The member mock-ups disagree. Home's requested Silver tier and 500 points to Gold conflict with Rewards' 680,000 point display; this seed deliberately follows Rewards (Silver / 680,000 / 500) and shares that exact record across both screens.

## Motion

Named durations/curve live in `lib/core/motion/motion.dart`. The UI includes auth progress, button press/loading, OTP error movement, carousel, product Hero and quantity transitions, reward ring count/sweep, tier display, tab movement and staggered challenge entrance. The primary loop/carousel checks Reduce Motion. SVG artwork is authored in-repo; no third-party image assets are used.

## Tests and builds

```sh
dart format lib test integration_test
dart run flutter analyze
flutter test
flutter build apk --release
flutter build ios --simulator
```

The initial package resolution was blocked by network access to pub.dev, so Riverpod/go_router and declared platform packages may not be fetched yet. Build/test outcomes must be recorded after dependencies are available. For the iOS simulator archive, run `flutter build ios --simulator`, then zip `build/ios/iphonesimulator/Runner.app`.

## Known gaps

- Package resolution not verified; requested Riverpod/go_router/Drift/secure storage/connectivity packages are declared but no generated code is present.
- Current seed reader is bundled JSON in memory, not Drift/SQLite. No remote server, connectivity_plus or reachability implementation.
- Current fake auth/session is in-memory; relaunch restoration is not durable. OTP countdown only persists for the current route instance.
- Social/legal flows are explanatory placeholders. Cart action gives visual feedback but does not persist.
- Integration/behavioral coverage and platform builds remain to be run after package resolution succeeds. No screen recording or public repository was created.
- Time spent: approximately 3 hours of implementation work; not independently timed.
