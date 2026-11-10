# J’Donuts Code Test Requirements

Audit of the 15-page brief and reference designs. The source PDF and its screenshots stay outside this repository.

Status: **Done** means implemented and covered by a completed relevant check; **Implemented** means source is present but still awaits its platform/integration check; **Partial** means intentionally limited as described; **Blocked** means the local environment did not permit verification.

## Project foundation

- [x] Flutter project kept in place; Flutter 3.47.5 stable / Dart 3.13.4. Riverpod 3, go_router, Drift, SQLite, secure storage and gen-l10n are in use.
- [x] Feature-first `auth`, `home`, `product`, `rewards`; presentation/data/domain separation; domain imports no Flutter libraries. Typed `Result` / `Failure`; immutable feature models.
- [x] Riverpod providers own repository, database, connectivity, router, session and draft dependencies. go_router has an auth redirect guard and `/product/:id`.
- [x] Theme and motion tokens centralized; English ARB/generated localization. Drift schema has a version number and migration hook.

## Authentication

- [x] Onboarding → phone → OTP → name → DOB → welcome → Home; returning user → phone → OTP → Home. Unknown numbers can start registration. Back navigation preserves the in-memory draft.
- [x] Fake repository waits about one second (delay injectable), prevents concurrent UI requests and exposes typed failures.
- [x] Pure phone, OTP, name and DOB rules. Phone strips whitespace/dashes and one leading zero; `+95` followed by `9` and seven to nine more digits. Invalid phone appears after blur.
- [x] OTP is six digits, fake code `123456`, paste/autofill and numeric keyboard; bad entry shakes/clears, third failure locks until resend is eligible; five-minute deadline lives in draft state across auth-step navigation.
- [x] First name required, last optional, trim/50 chars/Unicode letters and spaces; DOB calendar-valid, not future, age 13+ via named constant.
- [x] Durable account in SQLite, session identifier in `flutter_secure_storage`, session restore and Settings logout. Social and legal actions explain that the demo has no connected provider/document.
- [x] Tests: validator boundaries including Myanmar, phone normalization, leap day, invalid/future DOB and exact 13th birthday (`test/domain/validators_test.dart`); OTP policy/timing (`test/features/auth/otp_policy_test.dart`); repository/auth paths and duplicate submissions (`test/features/auth/auth_repository_test.dart`, `test/features/auth/auth_flow_widget_test.dart`); SQLite/session repository recreation (`test/features/auth/auth_persistence_test.dart`); auth UI (`test/widget_test.dart`).

## Offline Home and Product

- [x] Bundled JSON seeds SQLite on first read; Home, product and rewards read repository data backed by SQLite. Seed is transactional and safe under overlapping first reads. Schema version is 1.
- [x] Bundled original SVG assets mean first-launch content and product art do not need a network. `SeedImage` supplies asset/remote image rendering and failure/placeholder states; remote rasters use disk cache.
- [x] Home has member header, notification badge, autoplay banner, Seasonal/Popular/Order again, discounts and four shops. Home and Rewards consume the same row: Silver, 680,000 points, 500 to Gold. This resolves the conflicting mock-up numbers in favor of the Rewards balance while retaining the Home Gold-progress copy.
- [x] Each product opens `/product/:id` with code, name, New badge, description, MMK price, min quantity 1, animated count/live total and add-to-cart feedback.
- [x] Loading/error/retry states; Home has a section/list skeleton. `connectivity_plus` interface state is combined with an HTTP reachability probe. Pull-to-refresh and reconnect re-read SQLite without clearing existing rows.
- [ ] **Partial by design:** no backend is supplied; refresh means reloading the local database and does not fetch newer catalog data. The reachability probe targets Google’s `generate_204`; it is only a connectivity hint, not an application API.
- [x] Tests: seed groups/version, concurrent seed, offline DB reads (`test/features/home/local_data_repository_test.dart`); reachability combinations (`test/core/network/network_reachability_test.dart`); Home/product at 320×667 and scale 1.3, offline/reconnect and product navigation (`test/features/home/home_layout_widget_test.dart`).

## Rewards and motion

- [x] Custom-painted points ring and count-up; staggered Silver/Gold/Platinum ladder with current tier and next-tier progress; Earn/Gift animated indicator and content; staggered challenges; quarter donut artwork and coffee 9/12; completed/incomplete Earn behavior; badge entrance; sliding bottom-navigation pill.
- [x] Onboarding, auth step/progress/check, welcome, Home entrance, product Hero, quantity and button press/loading transitions.
- [x] Motion duration/curve tokens centralized. `MediaQuery.disableAnimations` skips entrances, count-up/sweep, loops/carousel and uses determinate loading indicators. Timers/controllers are disposed.
- [x] Responsive widget coverage at narrow portrait size and text scale 1.3; Rewards tab/Reduce Motion checks (`test/features/rewards/rewards_widget_test.dart`).
- [ ] **Partial:** claiming a challenge provides feedback within the current screen but does not persist a claim or mutate the shared points record. Cart addition is visual feedback only.

## Verification and delivery

- [x] `dart format lib test integration_test`, `flutter gen-l10n`, `flutter analyze`, `flutter test`: completed on 2026-11-10; 32 Flutter tests passed, analyzer reported no issues.
- [x] iOS Simulator integration test: register → welcome → Home → product, with production SQLite account storage, `flutter_secure_storage` session and forced offline state; recreates the app/provider scope and verifies offline session restoration. Completed 2026-11-10; one test passed.
- [x] Android release APK built at `build/app/outputs/flutter-apk/app-release.apk` (61 MB); archive, package/SDK metadata and V2 signature verified. Built with `:app:assembleRelease` while excluding Android `lintVital*` tasks because their first-use report artifacts stalled; Dart analyze/tests passed separately. Release uses the starter project's debug signing config.
- [x] Release iOS Simulator `.app` built and zipped: `build/ios/iphonesimulator/Runner.app`, `build/jdonuts-ios-simulator.zip` (66 MB). The simulator GUI screenshot verification remains unavailable (simulator reported a data migration failure and captured black output).
- [x] README, interview walkthrough and this checklist document setup, design choices, tests and known gaps. PDF/screenshots are excluded.
- [x] Small local commits created: `0830abc` architecture/storage, `a6add49` authentication, `7ddd357` offline screens, `91f6d10` relaunch test, `b6fb095` delivery docs, `0c16aa6` verification audit, `69ccde1` artifact/docs, `ab0494c` final audit. No push/publication.
