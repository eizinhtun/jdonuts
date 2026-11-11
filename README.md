# J’Donuts Flutter Code Test

Offline-first Flutter implementation of the supplied Madivizion code test. The client PDF and design screenshots are not stored in this repository.

## Run locally

The latest stable release verified on 2026-11-11 is Flutter 3.47.9 with Dart 3.13.7, listed in the [Flutter changelog](https://github.com/flutter/flutter/blob/master/CHANGELOG.md). Android SDK is required for Android builds; Xcode is required for iOS Simulator builds.

The existing workspace SDK is Flutter 3.47.5 / Dart 3.13.4. The full test suite and platform builds passed with that SDK. A separate Flutter 3.47.9 / Dart 3.13.7 checkout passed formatting, analysis, and the full unit/widget suite; the existing SDK checkout and project lockfile were left unchanged.

To install the verified stable release in a clean location:

    mkdir -p ~/development
    git clone --depth 1 --branch 3.47.9 https://github.com/flutter/flutter.git ~/development/flutter-3.47.9
    export PATH="$HOME/development/flutter-3.47.9/bin:$PATH"
    flutter --version

    flutter pub get
    flutter gen-l10n
    flutter run

Demo OTP: 123456. Returning demo phone: +95 987654321. Any valid new Myanmar mobile number can register locally.

## Verified toolchain

- Installed verification Flutter 3.47.5 stable, revision 6a19cca564; Dart 3.13.4
- Latest stable release checked in the upstream changelog and tested separately: Flutter 3.47.9 / Dart 3.13.7; formatting, `flutter analyze`, and all 93 unit/widget tests passed
- Xcode 27.1, build 27A9275
- macOS 27.0.1, arm64
- Resolved direct packages include Riverpod 3.5.0, go_router 16.3.0, Drift 2.35.4, flutter_secure_storage 9.2.4, connectivity_plus 7.3.2, cached_network_image 3.4.1, and flutter_svg 2.3.2. pubspec.lock contains the full resolved graph.

## Architecture

The code is organized by auth, home, product, and rewards features. Each feature separates presentation, domain contracts/models, and data adapters. Domain code does not import Flutter. Repositories return typed Result values with typed Failure variants; models are immutable. Infrastructure failures retain their cause and stack trace for diagnosis while UI surfaces use safe localized messages rather than raw exception text.

Theme colors, common spacing values, and shared text roles live in `lib/core/theme/tokens.dart`. Home and Rewards reuse those tokens; dimensions and styles tied to a specific reference composition stay with the component that owns that layout.

Riverpod is used for dependency injection and state. Providers construct the database, repositories, reachability service, session restore, router state, and auth draft. Tests override providers to supply in-memory storage, controlled clocks, delays, and connectivity streams. go_router applies the session guard and provides the stable /product/:id route.

Folder map:

- lib/app: provider graph and router
- lib/core: Result/Failure, Drift database, reachability, theme and motion tokens, currency formatting, and shared presentation helpers
- lib/features/auth: pure validation and OTP policy, repository contract, local fake, account/session stores, and flow UI
- lib/features/home: shared immutable catalog models, HomeRepository, SQLite adapter, and Home UI/widgets
- lib/features/product: ProductRepository, local adapter, and detail UI
- lib/features/rewards: RewardsRepository, local adapter, painters, and UI/widgets
- assets/data: bundled seed JSON and English ARB source
- assets/images: bundled SVG artwork and original offline raster images
- lib/l10n: generated localization code
- test and integration_test: unit, repository, widget, and device-flow checks

## Offline data and images

The first local repository read seeds bundled JSON into versioned Drift/SQLite tables in a transaction. The database is the rendered source of truth after seeding. Home, Product, and Rewards read through feature-local repository interfaces backed by the same catalog/member records. Schema v2 added the member avatar column; schema v3 migrates the bundled image paths; schema v4 and v5 migrate the untouched demo member balance while preserving other locally edited records.

Home and Rewards now read the same persisted Silver member with 680,000 points and 500 points remaining to Gold. Rewards counts up to 680,000 and fills 68% of its 1,000,000-point ring range; the remaining 32% stays grey. The Silver-to-Gold ladder uses its separate tier threshold (`points / (points + pointsToGold)`). Schema v5 returns only the untouched demo balance from 1,000,000 to 680,000; other member rows and edited balances remain unchanged. The seed does not provide a Gold-to-Platinum threshold, so the UI does not fabricate that later-tier progress.

Challenge counters, art fractions, completion states, and earnable point labels are normalized from their persisted challenge rows. Zero targets are incomplete and render zero progress; negative or over-target values are clamped. Earn only displays placeholder feedback and does not change the member balance or challenge record. Gift switches the displayed tab content without a redemption operation.

The onboarding hero donut, coconut and chocolate donuts, Dalgona coffee, seasonal donut box, shop banner, and nearby-shops pastry display are original images generated specifically for this app with OpenAI image generation; they are not stock photography. The vector donut and striped-donut Welcome tiles and member avatar are hand-authored SVG illustrations. The PDF and its screenshots are not bundled. SeedImage renders bundled SVG, PNG, and JPEG assets offline and supports cached remote raster images, placeholders, and an error view if a future data source supplies URLs. Drift schema v3 migrates previously seeded image paths to the bundled photos without replacing custom image paths; v4 migrates only the untouched demo member balance.

connectivity_plus interface changes are combined with an HTTP reachability probe. `NetworkStatus` keeps interface availability separate from internet reachability and reports unknown status when a probe fails. Home shows an offline or status-check notice, refreshes on reconnection and pull-to-refresh, and coalesces overlapping refresh requests. Failed refreshes show localized generic feedback without clearing cached content. There is no backend in this assignment slice, so refresh re-reads SQLite and cannot download catalog updates; server-specific errors do not apply.

## Authentication

The replaceable AuthRepository uses a local fake implementation with an injectable one-second delay. OTP 123456 is test-only. Accounts persist in SQLite and flutter_secure_storage holds the active phone identifier. An absolute resend deadline and failure count live in the shared auth draft so route navigation does not reset them. Settings logs out and the router returns to the auth entry.

This does not provide real SMS delivery, social sign-in, legal-document destinations, or server authentication. The UI labels social/legal actions as placeholders.

## Motion and accessibility

Named motion durations and curves are centralized in lib/core/motion/motion.dart. The app includes onboarding and welcome entrances, registration transitions and progress feedback, auth error/OTP feedback, Home shimmer/stagger and carousel, Product Hero/quantity transitions, Rewards points/tier/challenge animations, tab transitions, badge pop, and the active navigation pill. Repeating motion is stopped and animated values settle when MediaQuery.disableAnimations is enabled. Controllers and timers are disposed with their owners. The PDF supplies no font file or family name. On iOS, the onboarding and registration headlines request the system SF Pro Rounded face as a local rounded fallback; the exact reference typeface remains unverified. Other text and Android use platform system sans.

## Checks run on 2026-11-11

- `dart format --output=none --set-exit-if-changed lib test integration_test` — passed; no formatting changes required
- `flutter analyze` — no issues found after this audit's source changes
- `flutter pub get --enforce-lockfile` — passed with the CI-pinned Flutter 3.47.9 / Dart 3.13.7
- `flutter gen-l10n` — completed after adding the localized unknown-network-status message
- `flutter test --concurrency=1` — all 93 unit and widget tests passed on Flutter 3.47.5 and the CI-pinned Flutter 3.47.9.
- `flutter test integration_test/registration_to_product_test.dart -d 19EA97F4-DD99-47EF-BAA2-516BADF6E230` — passed on the booted iPhone 17 Pro Simulator, including offline seed/render, product routing and session restoration.
- `flutter build apk --release --target-platform android-arm64` — passed; current APK is 34.0 MB.
- `flutter build ios --simulator` — passed; `build/jdonuts-ios-simulator-current.zip` passed `unzip -t`. iOS Simulator builds are debug configuration because Flutter does not support release mode for Simulator.
- `flutter drive --profile` could not profile on the simulator because Flutter does not support profile builds for iOS Simulator. The connected physical iPhone requires Developer Mode; no Android device is available for the requested mid-range profile.
- The current Android release APK is arm64-only and signed with the demo debug signing config. Configure production signing before distribution.
- The existing `build/jdonuts-demo-walkthrough.mov` is 211 seconds (3:31), but it predates the final visual pass. A fresh recording of the current UI was not verified, so treat this video as an older walkthrough.
- Captured and reviewed all ten supplied design states on an iPhone 17 Pro Simulator on 2026-11-11. The review was visual; no pixel-diff tool was used.

Profile timing remains unverified. The trace test is available at `integration_test/rewards_performance_test.dart`; this run was rejected for iOS Simulator before profile instrumentation could start, and the connected physical phone requires Developer Mode. No frame timings or 60 fps claim are available. The integration fixture forces the app's network provider offline, but system airplane mode was not toggled. No pixel-diff comparison was captured.

## Build artifacts and commands

Current Android release APK (arm64 only, signed with the project's demo debug signing config):

    flutter build apk --release --target-platform android-arm64

Output: build/app/outputs/flutter-apk/app-release.apk. Configure a production application ID and signing key before distribution.

iOS Simulator app:

    flutter build ios --simulator
    ditto -c -k --sequesterRsrc --keepParent build/ios/iphonesimulator/Runner.app build/jdonuts-ios-simulator-current.zip

The `.app` and zip are local workspace artifacts and were not published or submitted. Flutter rejects `--release` for Simulator builds. A signed iPhone device/App Store archive requires a configured Apple team and provisioning profile.

## Known gaps and scope

- There is no server, live catalog sync, SMS provider, social auth provider, or legal document content.
- Add-to-cart and challenge Earn feedback are transient; they do not persist or change the member balance.
- Burmese localization is an optional PDF bonus and is not implemented. GitHub Actions CI runs formatting, analysis, and the unit/widget suite on pushes, pull requests, and manual dispatch.
- The current forced-offline iOS integration path passed. A physical system airplane-mode/relaunch check remains unverified.
- Flutter 3.47.9 / Dart 3.13.7 is the latest stable release confirmed upstream; formatting, analysis, lockfile resolution and the full unit/widget suite passed. Integration and platform build checks used Flutter 3.47.5 / Dart 3.13.4.
- Layouts are tested at a compact 320×667 logical-pixel viewport with text scale 1.3, not every physical 4.7–6.9 inch device size.
- The bundled original food photos approximate the reference imagery; they are not photos of the client’s actual products or shops. Two Welcome tiles use those generated donut photos; the other two use vector illustrations.
- Android release APK signing is for the demo, and only arm64 is packaged.
- Time spent was not tracked, so no duration is claimed.
- No repository was published, and no email or external submission was made.
