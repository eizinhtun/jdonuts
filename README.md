# J’Donuts Flutter Code Test

Offline-first Flutter implementation of the supplied Madivizion code test. The client PDF and design screenshots are not stored in this repository.

## Run locally

The latest stable release verified on 2026-11-11 is Flutter 3.47.9 with Dart 3.13.7, listed in the [Flutter changelog](https://github.com/flutter/flutter/blob/master/CHANGELOG.md). Android SDK is required for Android builds; Xcode is required for iOS Simulator builds.

This workspace's installed SDK is Flutter 3.47.5 / Dart 3.13.4. The project was analyzed with it, but the 3.47.9 SDK was not installed here: the existing Flutter checkout has a modified SDK `pubspec.lock`, and a separate checkout could not finish installing before the filesystem ran out of space. Latest stable runtime/build compatibility therefore remains unverified in this workspace.

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
- Latest stable release checked: Flutter 3.47.9 / Dart 3.13.7; current project sources still use only APIs available in 3.47.5, but the newer SDK was not installed for a build check
- Xcode 27.1, build 27A9275
- macOS 27.0.1, arm64
- Resolved direct packages include Riverpod 3.5.0, go_router 16.3.0, Drift 2.35.4, flutter_secure_storage 9.2.4, connectivity_plus 7.3.2, cached_network_image 3.4.1, and flutter_svg 2.3.2. pubspec.lock contains the full resolved graph.

## Architecture

The code is organized by auth, home, product, and rewards features. Each feature separates presentation, domain contracts/models, and data adapters. Domain code does not import Flutter. Repositories return typed Result values with typed Failure variants; models are immutable. Infrastructure failures retain their cause and stack trace for diagnosis while UI surfaces use safe localized messages rather than raw exception text.

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

The first local repository read seeds bundled JSON into versioned Drift/SQLite tables in a transaction. The database is the rendered source of truth after seeding. Home, Product, and Rewards read through feature-local repository interfaces backed by the same catalog/member records. Schema v2 added the member avatar column; schema v3 migrates the bundled image paths.

The Home and Rewards mock-ups disagree about membership values. The app deliberately uses one seeded Silver member with 680,000 points and 500 points to Gold, matching the Rewards values. The count-up target is the persisted `member.points` value (680,000). The ring and Silver-to-Gold connector use `points / (points + pointsToGold)`, or 680,000 / 680,500 for this member, so the saved 500-point remainder produces a nearly full progress arc. The current seed only stores a Silver-to-Gold remainder; it does not provide a Gold-to-Platinum threshold, so the UI does not fabricate that later-tier progress.

Challenge counters, art fractions, completion states, and earnable point labels are normalized from their persisted challenge rows. Zero targets are incomplete and render zero progress; negative or over-target values are clamped. Earn only displays placeholder feedback and does not change the member balance or challenge record. Gift switches the displayed tab content without a redemption operation.

The onboarding hero donut, coconut and chocolate donuts, Dalgona coffee, seasonal donut box, and shop banner are original images generated specifically for this app with OpenAI image generation; they are not stock photography. The vector donut and striped-donut Welcome tiles and member avatar are hand-authored SVG illustrations. The PDF and its screenshots are not bundled. SeedImage renders bundled SVG, PNG, and JPEG assets offline and supports cached remote raster images, placeholders, and an error view if a future data source supplies URLs. Drift schema v3 migrates previously seeded image paths to the bundled photos without replacing custom image paths.

connectivity_plus interface changes are combined with an HTTP reachability probe. `NetworkStatus` keeps interface availability separate from internet reachability and reports unknown status when a probe fails. Home shows an offline or status-check notice, refreshes on reconnection and pull-to-refresh, and coalesces overlapping refresh requests. Failed refreshes show localized generic feedback without clearing cached content. There is no backend in this assignment slice, so refresh re-reads SQLite and cannot download catalog updates; server-specific errors do not apply.

## Authentication

The replaceable AuthRepository uses a local fake implementation with an injectable one-second delay. OTP 123456 is test-only. Accounts persist in SQLite and flutter_secure_storage holds the active phone identifier. An absolute resend deadline and failure count live in the shared auth draft so route navigation does not reset them. Settings logs out and the router returns to the auth entry.

This does not provide real SMS delivery, social sign-in, legal-document destinations, or server authentication. The UI labels social/legal actions as placeholders.

## Motion and accessibility

Named motion durations and curves are centralized in lib/core/motion/motion.dart. The app includes onboarding and welcome entrances, registration transitions and progress feedback, auth error/OTP feedback, Home shimmer/stagger and carousel, Product Hero/quantity transitions, Rewards points/tier/challenge animations, tab transitions, badge pop, and the active navigation pill. Repeating motion is stopped and animated values settle when MediaQuery.disableAnimations is enabled. Controllers and timers are disposed with their owners. The PDF supplies no font file or family name. On iOS, the onboarding and registration headlines request the system SF Pro Rounded face as a local rounded fallback; the exact reference typeface remains unverified. Other text and Android use platform system sans.

## Checks run on 2026-11-11

- `dart format --output=none --set-exit-if-changed lib test integration_test` — passed; no formatting changes required
- `flutter analyze` — no issues found after this audit's source changes
- `flutter gen-l10n` — completed after adding the localized unknown-network-status message
- First `flutter test` run reached 88 passing tests and one failed offline-banner assertion caused by a one-frame stream update delay. The test was corrected; `flutter test test/features/home/home_layout_widget_test.dart` then passed all 8 Home tests, including refresh coalescing.
- Full-suite rerun did not complete: the filesystem ran out of space while Flutter copied `output.dill` to the test listener. The network tests emitted four passing assertions before that setup error. This run is not counted as a passing full suite.
- Auth repository and reachability tests also completed successfully during the first full-suite run; the updated cause/message assertions were included. A standalone rerun was blocked by the same output-copy disk-space error.
- Integration test and Android/iOS build commands were not rerun after these source changes because available disk space fell below the required amount. Earlier revision results are not treated as current build verification.
- An earlier Android arm64 debug build passed after the Task 3 changes; it predates this audit's source edits and is not current build verification.
- Profile command when device Developer Mode is enabled: `flutter drive --profile -d <device-id> --driver=test_driver/rewards_performance_test.dart --target=integration_test/rewards_performance_test.dart`. The connected phone rejected the current attempt before build because Developer Mode is disabled.
- Android release build: arm64 APK built at build/app/outputs/flutter-apk/app-release.apk (32.3 MB); apksigner verified its v2 signature.
- iOS Simulator app built with flutter build ios --simulator and zipped at build/jdonuts-ios-simulator-current.zip; archive integrity check passed. Flutter does not support release mode for iOS simulators, so this is a debug Simulator app.
- The existing `build/jdonuts-demo-walkthrough.mov` is 211 seconds (3:31), but it predates the final visual pass. A fresh recording of the current UI was not verified, so treat this video as an older walkthrough.
- Captured and reviewed all ten supplied design states on an iPhone 17 Pro Simulator on 2026-11-11. The review was visual; no pixel-diff tool was used.

Profile timing remains unverified. A profile trace test is available at `integration_test/rewards_performance_test.dart`, but the earlier `flutter drive --profile` attempt stopped before building because the connected iPhone requires Developer Mode to be enabled in Settings. No frame timings were collected and no 60 fps claim is made. System-level airplane mode was not toggled. A booted iPhone 17 Pro Simulator is available, but the current Register → Product integration test was not rerun because of disk space. Android runtime/offline behavior also remains unverified in this pass.

## Build artifacts and commands

Previously generated Android release APK (arm64 only, signed with the project's demo debug signing config; predates this audit's source edits):

    flutter build apk --release --target-platform android-arm64

Output: build/app/outputs/flutter-apk/app-release.apk. Configure a production application ID and signing key before distribution.

iOS Simulator app:

    flutter build ios --simulator
    ditto -c -k --sequesterRsrc --keepParent build/ios/iphonesimulator/Runner.app build/jdonuts-ios-simulator-current.zip

The earlier `.app` and zip are local workspace artifacts and were not published or submitted. They predate this audit's source edits. Flutter rejects `--release` for Simulator builds. A signed iPhone device/App Store archive requires a configured Apple team and provisioning profile.

## Known gaps and scope

- There is no server, live catalog sync, SMS provider, social auth provider, or legal document content.
- Add-to-cart and challenge Earn feedback are transient; they do not persist or change the member balance.
- Burmese localization and CI are optional PDF bonuses and are not implemented.
- Offline repository behavior and a forced-offline iOS integration path passed on an earlier revision; they were not rerun after this audit's provider changes. A full fresh-install airplane-mode/relaunch device check remains unverified.
- The latest stable SDK was verified from upstream release information but could not be installed for local verification. The first full test run found one test timing issue, which was fixed and covered by the passing Home suite; the full suite rerun was blocked by the host's full filesystem.
- Layouts are tested at a compact 320×667 logical-pixel viewport with text scale 1.3, not every physical 4.7–6.9 inch device size.
- The bundled original food photos approximate the reference imagery; they are not photos of the client’s actual products or shops. Two Welcome tiles use those generated donut photos; the other two use vector illustrations.
- Android release APK signing is for the demo, and only arm64 is packaged.
- Time spent was not tracked, so no duration is claimed.
- No repository was published, and no email or external submission was made.
