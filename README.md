# J’Donuts Flutter Code Test

Offline-first Flutter implementation of the supplied Madivizion code test. The client PDF and design screenshots are not stored in this repository.

## Run locally

Requires Flutter 3.47.5 stable / Dart 3.13.4, Android SDK for Android, and Xcode for iOS Simulator.

    flutter pub get
    flutter gen-l10n
    flutter run

Demo OTP: 123456. Returning demo phone: +95 987654321. Any valid new Myanmar mobile number can register locally.

## Verified toolchain

- Flutter 3.47.5 stable, revision 6a19cca564
- Dart 3.13.4
- Xcode 27.1, build 27A9275
- macOS 27.0.1, arm64
- Resolved direct packages include Riverpod 3.5.0, go_router 16.3.0, Drift 2.35.4, flutter_secure_storage 9.2.4, connectivity_plus 7.3.2, cached_network_image 3.4.1, and flutter_svg 2.3.2. pubspec.lock contains the full resolved graph.

## Architecture

The code is organized by auth, home, product, and rewards features. Each feature separates presentation, domain contracts/models, and data adapters. Domain code does not import Flutter. Repositories return typed Result values with typed Failure variants; models are immutable.

Riverpod is used for dependency injection and state. Providers construct the database, repositories, reachability service, session restore, router state, and auth draft. Tests override providers to supply in-memory storage, controlled clocks, delays, and connectivity streams. go_router applies the session guard and provides the stable /product/:id route.

Folder map:

- lib/app: provider graph and router
- lib/core: Result/Failure, Drift database, reachability, theme and motion tokens, currency formatting, and shared presentation helpers
- lib/features/auth: pure validation and OTP policy, repository contract, local fake, account/session stores, and flow UI
- lib/features/home: shared immutable catalog models, HomeRepository, SQLite adapter, and Home UI/widgets
- lib/features/product: ProductRepository, local adapter, and detail UI
- lib/features/rewards: RewardsRepository, local adapter, painters, and UI/widgets
- assets/data: bundled seed JSON and English ARB source
- assets/images: original offline SVG illustrations
- lib/l10n: generated localization code
- test and integration_test: unit, repository, widget, and device-flow checks

## Offline data and images

The first local repository read seeds bundled JSON into versioned Drift/SQLite tables in a transaction. The database is the rendered source of truth after seeding. Home, Product, and Rewards read through feature-local repository interfaces backed by the same catalog/member records. A schema migration adds the member avatar column.

The Home and Rewards mock-ups disagree about membership values. The app deliberately uses one seeded Silver member with 680,000 points and 500 points to Gold, matching the Rewards values. The rewards ring counts to 680,000 from this stored member row.

Seed products, banners, and the member avatar use original hand-authored SVG artwork. No third-party image or PDF screenshot is bundled. SeedImage renders bundled files offline and supports cached remote raster images, placeholders, and an error view if a future data source supplies URLs.

connectivity_plus interface changes are combined with an HTTP reachability probe. A small offline banner appears when the probe reports no internet. Reconnection and pull-to-refresh re-read SQLite, preserving usable content. There is no backend in this assignment slice, so refresh cannot download catalog updates; the reachability request is only an online/offline hint.

## Authentication

The replaceable AuthRepository uses a local fake implementation with an injectable one-second delay. OTP 123456 is test-only. Accounts persist in SQLite and flutter_secure_storage holds the active phone identifier. An absolute resend deadline and failure count live in the shared auth draft so route navigation does not reset them. Settings logs out and the router returns to the auth entry.

This does not provide real SMS delivery, social sign-in, legal-document destinations, or server authentication. The UI labels social/legal actions as placeholders.

## Motion and accessibility

Named motion durations and curves are centralized in lib/core/motion/motion.dart. The app includes onboarding and welcome entrances, registration transitions and progress feedback, auth error/OTP feedback, Home shimmer/stagger and carousel, Product Hero/quantity transitions, Rewards points/tier/challenge animations, tab transitions, badge pop, and the active navigation pill. Repeating motion is stopped and animated values settle when MediaQuery.disableAnimations is enabled. Controllers and timers are disposed with their owners.

## Checks run on 2026-11-10

- dart format lib test integration_test — completed
- flutter gen-l10n — completed
- flutter analyze — no issues found
- flutter test --reporter expanded — all 44 tests passed
- Android emulator integration: registration → Welcome → offline Home → Product → app-scope recreation/session restore — passed
- iOS Simulator integration: same flow — passed
- Android release build: arm64 APK built at build/app/outputs/flutter-apk/app-release.apk (25.3 MB); apksigner verified the v2 signature
- iOS Simulator app built with flutter build ios --simulator and zipped at build/jdonuts-ios-simulator-current.zip; archive integrity check passed. Flutter does not support release mode for iOS simulators, so this is a debug Simulator app.
- iOS Simulator walkthrough recording test passed; `build/jdonuts-demo-walkthrough.mov` is 211 seconds (3:31) and ends on Rewards.
- Simulator launch and onboarding were visually inspected. Full screen-by-screen pixel comparison was not completed.

No profile-mode frame timing was recorded; no 60 fps claim is made. The integration test forces its connectivity provider offline and tests reconnection through a simulated stream. System-level airplane mode was not toggled.

## Build artifacts and commands

Android release APK (arm64 only, signed with the project’s demo debug signing config):

    flutter build apk --release --target-platform android-arm64

Output: build/app/outputs/flutter-apk/app-release.apk. Configure a production application ID and signing key before distribution.

iOS Simulator app:

    flutter build ios --simulator
    ditto -c -k --sequesterRsrc --keepParent build/ios/iphonesimulator/Runner.app build/jdonuts-ios-simulator-current.zip

The .app and zip are local workspace artifacts. They were not published or submitted. Flutter rejects --release for Simulator builds. A signed iPhone device/App Store archive requires a configured Apple team and provisioning profile.

## Known gaps and scope

- There is no server, live catalog sync, SMS provider, social auth provider, or legal document content.
- Add-to-cart and challenge Earn feedback are transient; they do not persist or change the member balance.
- Burmese localization and CI are optional PDF bonuses and are not implemented.
- Offline repository behavior and the forced-offline integration path are verified; a full fresh-install airplane-mode/relaunch device check remains unverified.
- Layouts are tested at a compact 320×667 logical-pixel viewport with text scale 1.3, not every physical 4.7–6.9 inch device size.
- Original SVG artwork differs from the PDF’s photographic product imagery. Visual review was a spot-check, not a pixel-diff of every design.
- Android release APK signing is for the demo, and only arm64 is packaged.
- Time spent was not tracked, so no duration is claimed.
- No repository was published, and no email or external submission was made.
