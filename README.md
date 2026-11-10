# J’Donuts Flutter Code Test

Offline-first demo for the supplied Madivizion code test. The PDF and client design screenshots are deliberately not stored in this repository.

## Run locally

Requires Flutter 3.47.5 stable / Dart 3.13.4 (or a compatible newer stable toolchain), Xcode for iOS, and Android SDK/accepted Android licenses for Android.

```sh
flutter pub get
flutter run
```

Demo OTP: `123456`. Returning demo account: `+95 987654321` (normalized to `95987654321`). Any valid new Myanmar mobile number can register locally.

## Tested versions

- Flutter: 3.47.5 stable
- Dart: 3.13.4
- Xcode: 27.1
- macOS: 27.0.1, arm64
- Direct package versions resolved during verification: Riverpod 3.5.0, go_router 16.3.0, Drift 2.35.4, flutter_secure_storage 9.2.4, connectivity_plus 7.3.2, http 1.6.0, cached_network_image 3.4.1, flutter_svg 2.3.2, intl 0.20.3, path_provider 2.1.6, sqlite3_flutter_libs 0.5.42. `pubspec.lock` records the full dependency graph.

## Architecture

`lib/features/{auth,home,product,rewards}` are feature-first and separate `domain`, `data`, and `presentation` responsibilities. Domain validators/repository contracts are plain Dart and do not import Flutter. Repositories return typed `Result<T>` values with typed failures; screen-facing models are immutable.

`lib/app/providers.dart` uses Riverpod for dependency injection and app state: repositories, Drift database, connectivity, session restore, router refresh and the auth draft. Riverpod keeps widget constructors simple and makes clocks, delays, stores and streams replaceable in tests. `lib/app/router.dart` owns navigation and the session-aware auth redirect. `/product/:id` receives a stable product ID and Hero tag.

Folder map:

- `lib/app/`: dependency providers and go_router configuration.
- `lib/core/`: Result/Failure, SQLite, network reachability, theme/motion tokens, formatting and shared presentation widgets.
- `lib/features/auth/`: auth interface, fake repository, Drift account store, secure session adapter, validators, OTP policy and flow screens.
- `lib/features/home/`: seed/database repository, immutable shared models and Home UI.
- `lib/features/product/`, `lib/features/rewards/`: focused screen implementations.
- `lib/l10n/` + `assets/data/strings_en.arb`: generated English localization. Change the ARB, then run `flutter gen-l10n`.
- `assets/data/seed.json`, `assets/images/`: bundled offline content.
- `test/`, `integration_test/`: pure/unit, repository, widget and device flow coverage.

## Offline data and images

The first repository read transactionally seeds the versioned Drift/SQLite database from bundled JSON. Screens read the database-backed repository, not widget-local sample lists. A shared member row feeds both Home and Rewards. Their mock-ups conflict: the implementation uses Silver / 680,000 points / 500 remaining to Gold from the Rewards view, while retaining the Home screen’s Gold-progress copy.

Products and banners use original, hand-authored SVG illustrations under `assets/images/`; no third-party image is used. Local artwork makes the first launch work without internet. `SeedImage` also supports remote raster image loading with disk caching, placeholders and error rendering if a future data source supplies URLs.

`connectivity_plus` reports interface changes, and an HTTP `generate_204` probe checks actual reachability. Pull-to-refresh and reconnect refresh re-read local SQLite and keep the current content. There is no backend in this demo, so these refreshes do not download new catalog content. The Google probe is a connectivity hint, not a service contract.

The fake auth repository waits approximately one second per request by default. The local demo OTP is `123456`. OTP resend state and failed-attempt count live in the auth draft so changing auth routes does not reset the timer. User accounts persist in SQLite, and the active phone identifier uses `flutter_secure_storage`. Settings clears the session and logs out.

## Motion and accessibility

Named durations/curves are in `lib/core/motion/motion.dart`. The UI includes onboarding and Home entrances, auth step/progress feedback, button loading/press states, OTP shake, carousel, product Hero/quantity transitions, a custom-painted rewards ring, tier/challenge entrances, animated Earn/Gift content, badge pop and active navigation pill. Reduce Motion disables looping carousel/attention motion and skips or settles entrance/progress animation. Timers/controllers are disposed with their screens.

## Checks run

The following completed on 2026-11-10:

```sh
dart format lib test integration_test
flutter gen-l10n
flutter analyze
flutter test
```

Formatting and localization generation completed, analyzer had no issues, and all 32 Flutter tests passed. Repository and widget tests cover seed/versioning/concurrent seed, offline reads, reachability, auth/OTP/validation/session paths, Home/product layout at text scale 1.3, Rewards tabs and Reduce Motion.

The iOS Simulator integration flow also passed: register → Welcome → offline Home → product, using production SQLite account storage and the secure-session plugin. The Release Simulator app is zipped at `build/jdonuts-ios-simulator.zip`. The Android APK and visual screenshot comparison remain explicitly tracked in `REQUIREMENTS.md`; check there for current status. **Time spent was not recorded with a timer, so no precise total is claimed.**

## Build commands

```sh
# Android release APK (uses the project’s debug signing config for this demo)
flutter build apk --release

# iOS Simulator app
flutter build ios --simulator
ditto -c -k --sequesterRsrc --keepParent \
  build/ios/iphonesimulator/Runner.app build/jdonuts-ios-simulator.zip
```

Android output: `build/app/outputs/flutter-apk/app-release.apk`. iOS output: `build/ios/iphonesimulator/Runner.app`. A simulator `.app` is for Simulator use and is not an App Store archive. For an iPhone device/App Store build, configure a valid Apple team and signing profile in Xcode.

## Known limits

- No remote API/server, live catalog refresh, SMS provider, social auth provider or legal document destinations are connected; those actions say so in the UI.
- Add-to-cart and challenge claim feedback are local/transient and do not persist or update the member balance.
- Visual design comparison needs a functioning simulator GUI; report the environment’s current visual check in `REQUIREMENTS.md` rather than assuming pixel parity.
- Time spent was not instrumented. No repository push or public submission was made.
