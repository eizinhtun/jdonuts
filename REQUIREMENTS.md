# J’Donuts Code Test — Verified Requirements Audit

The attached 15-page Madivizion brief and its screen designs are the requirements source. The PDF describes **10 design screens** and a **9-screen flow**; “Name (empty)” and “Name (filled)” are two states of the same screen. The PDF and its client screenshots are intentionally kept outside this repository. No `AGENTS.md` file was present in the project or its parent directories during this audit.

Statuses mean: **Pass** = implemented and supported by a completed check; **Partial** = implemented with a stated test, scope, or visual gap; **Fail** = known missing mandatory behavior; **Unverified** = not checked in this environment.

## Mandatory requirements

| Requirement | Status | Code evidence | Verification |
|---|---|---|---|
| Current stable Flutter/Dart versions documented | Pass | `README.md`; `pubspec.lock` | `flutter --version` → Flutter 3.47.5 stable, Dart 3.13.4; `dart --version` → 3.13.4. |
| Feature-first clean layers for auth, home, product, rewards; Flutter-free domain | Pass | `lib/features/{auth,home,product,rewards}/{presentation,domain,data}/`; product/rewards repository adapters | `flutter analyze`; source inspection of all `*/domain/*.dart` imports. Shared immutable catalog entities remain in `home/domain/models.dart`; product and rewards adapters depend on the `HomeRepository` contract. |
| Riverpod DI/state, go_router guard, `/product/:id` | Pass | `lib/app/providers.dart`, `lib/app/router.dart` | Auth, welcome, product routes exercised in widget and device integration tests. |
| Drift/SQLite storage with versioned migration | Pass | `lib/core/storage/app_database.dart` (schema v3) | `test/features/home/local_data_repository_test.dart`: initial seed, v1→v2 member-image migration, and v2→v3 image-path migration. |
| Typed immutable domain models and `Result`/`Failure` | Pass | `lib/core/result/result.dart`; feature domain models and repository interfaces | Repository, storage, network and auth tests assert typed success/error behavior. |
| Auth fake repository, replaceable contract, ~1 s latency, local user store | Pass | `lib/features/auth/domain/auth_repository.dart`, `lib/features/auth/data/local_auth_repository.dart` | `test/features/auth/auth_repository_test.dart` verifies injected one-second delay, local registration and returning/unknown users. |
| Registration and returning-login routes; unknown number offers registration | Pass | `lib/features/auth/presentation/auth_flow.dart`, `lib/app/router.dart` | `test/widget_test.dart`; `integration_test/registration_to_product_test.dart` covers registration. |
| Secure session restore and Settings logout | Pass | `lib/features/auth/data/auth_session_store.dart`, `lib/features/auth/data/auth_account_store.dart`, `lib/features/auth/presentation/entry_screens.dart` | Auth persistence test and integration test recreate app/provider scope; widget test logs out. |
| Phone normalization and validation; invalid error after blur | Pass | `lib/features/auth/domain/validators.dart`, `lib/features/auth/presentation/auth_flow.dart` | Unit boundaries cover whitespace/dashes/one leading zero and length/prefix; widget test checks blur error. |
| OTP six digits, numeric input, progression, paste and SMS autofill hint | Pass | `lib/features/auth/presentation/auth_flow_inputs.dart` | Widget test pastes all six digits, checks focus progression/backspace and `AutofillHints.oneTimeCode`; native SMS delivery itself is platform-provided and was not simulated. |
| Wrong OTP shakes/clears; third failure locks; resend deadline starts/restarts at 5:00 | Pass | `lib/features/auth/domain/otp_policy.dart`, `lib/features/auth/presentation/auth_draft.dart`, `lib/features/auth/presentation/auth_flow.dart` | `test/features/auth/otp_policy_test.dart` and `auth_flow_widget_test.dart` use an injectable clock; verify lock, disabled fields and resend unlock without a real five-minute wait. |
| First/last-name rules including Myanmar Unicode | Pass | `lib/features/auth/domain/validators.dart` | `test/domain/validators_test.dart` covers required/optional, trimming, maximum length, digits and Myanmar letters. |
| DOB real calendar date, leap years, future and age 13 boundary | Pass | `lib/features/auth/domain/validators.dart` (`minimumAge`) | Validator tests cover invalid dates, leap day, future date, and exact/one-day-short thirteenth birthday. |
| Duplicate-submit prevention, loading, and back-value preservation | Pass | `lib/features/auth/presentation/auth_flow_actions.dart`, `auth_draft.dart` | Widget tests hold each phone, OTP, name and DOB request open and confirm a second tap does not duplicate it; another test checks back/forward value retention. |
| Social/legal placeholder feedback | Pass | `lib/features/auth/presentation/entry_screens.dart`, `auth_flow_forms.dart` | Actions show explicit placeholder feedback; verified by code inspection. |
| Seed bundled JSON into local DB; database is rendered source of truth | Pass | `assets/data/seed.json`, `lib/features/home/data/local_data_repository.dart` | Seed/version/concurrent-first-read/offline-read tests; Home, Product and Rewards repository adapters query the shared repository. |
| First offline launch and saved content/images | Partial | `assets/images/`, `lib/core/presentation/seed_image.dart`, local repository | The iOS integration fixture forces connectivity offline and checks first seed/Home/Product. Seed artwork is bundled. A system-level airplane-mode toggle/relaunch was not performed. |
| Image disk caching, placeholders and failure state | Pass | `lib/core/presentation/seed_image.dart`, `assets/images/` | Simulator captures verify bundled SVG/PNG/JPEG rendering offline. Remote raster cache uses `cached_network_image`; remote-cache behavior is not separately integration-tested. |
| `connectivity_plus` plus real reachability; offline banner and reconnect refresh | Pass | `lib/core/network/network_reachability.dart`, `lib/app/providers.dart`, `lib/features/home/presentation/home_screen.dart` | Reachability tests combine interface status and HTTP probe; Home widget test drives offline→online refresh and a pull gesture, confirming both refresh paths. |
| Refresh behavior with no backend | Partial | Home/Rewards repository `refresh()` | Refresh deliberately re-reads SQLite and preserves current content; it cannot download newer catalog data. Connectivity probe is a hint, not an API. |
| One shared member record, including 680,000 reward target | Pass | `assets/data/seed.json`; `lib/features/home/domain/models.dart`; `lib/features/rewards/data/local_rewards_repository.dart` | Seed/rewards repository tests verify Silver, 680,000 points and 500 to Gold all come from the same row. This resolves conflicting mock-ups by using Rewards’ Silver/680,000 and 500 remaining to Gold. |
| Home header, notification count, banner carousel, three sections, discounts, four shops | Pass | `lib/features/home/presentation/home_screen.dart`, seed data | Repository seed assertions; Home widget/integration flow. |
| Home skeleton and independent section empty/error/retry | Pass | `lib/features/home/presentation/widgets/home_skeleton.dart`, `home_screen.dart` | Skeleton Reduce Motion widget test; failed section retries without replacing other sections. |
| Every product tile routes to correct product detail | Pass | `lib/features/home/presentation/home_screen.dart`, `lib/features/product/domain/product_repository.dart` | iOS integration opens Coconut Donut and verifies its code/price. Product repository unit tests cover ID lookup/missing ID. |
| Product detail fields, MMK formatting, quantity min 1/live total, add feedback | Pass | `lib/features/product/presentation/product_screen.dart`, `lib/core/formatters/currency.dart` | Home/product widget test checks product code, New, 3,200→6,400 total, min 1 and add feedback; integration checks product screen. |
| Rewards painter, count-up, tier progress, tabs, challenges, progress artwork and Earn states | Pass | `lib/features/rewards/presentation/rewards_screen.dart`, `lib/features/rewards/presentation/widgets/points_ring.dart`, `points_ring_painter.dart` | Rewards widget tests at compact size/text scale 1.3, Reduced Motion and Earn/Gift interaction; Rewards repository verifies shared values. |
| Required transition/entrance/shimmer/Hero/button motion and named tokens | Pass | `lib/core/motion/motion.dart`, feature presentation files | Widget and integration tests exercise screen transitions, shimmer and product navigation; code inspection confirms named durations/curves. |
| `MediaQuery.disableAnimations` honored for loops and transitions | Pass | `lib/core/motion/motion.dart`, `home_screen.dart`, `home_skeleton.dart`, Rewards widgets | Reduced-motion Home and Rewards widget tests; animation helpers settle or disable repeats. |
| 4.7–6.9 inch portrait and text scale 1.3 | Partial | Home, Auth, Rewards, Product responsive layouts | Automated layouts use 320×667 and scale 1.3 for Home/Product/Rewards/Auth; only one compact viewport is checked, not the full physical-size range. |
| Profile-mode performance / 60 fps | Unverified | — | No profile-mode frame timing or mid-range physical-device measurement was recorded. No 60 fps claim is made. |
| ARB/gen-l10n, theme/color/spacing/motion tokens | Pass | `assets/data/strings_en.arb`, `lib/l10n/`, `lib/core/theme/tokens.dart`, `motion.dart` | `flutter gen-l10n`; analyzer. English only. |
| Clean analyzer and format | Pass | Project source | `dart format lib test integration_test`; `flutter analyze` reports no issues. |
| Unit/widget test requirements | Pass | `test/` | `flutter test --reporter expanded` passed all 46 tests, including validators, OTP, session, v1→v2 and v2→v3 migrations, reachability, reconnect and pull-to-refresh, repositories, Home/Product/Rewards and auth widgets. |
| Register→Welcome→Home→Product integration | Pass | `integration_test/registration_to_product_test.dart` | Passed on iOS Simulator with this UI revision; Android emulator integration could not be rerun because Pixel 10 Pro exited code 1 during startup. |
| Screenshot fidelity against all 10 designs | Partial | `lib/features/*/presentation/`, `assets/images/` | All ten states were captured and visually reviewed on iPhone 17 Pro Simulator with no layout exceptions; no pixel-diff tool was used. Original generated food photos approximate the reference; the member avatar and Welcome tiles remain vector illustrations. Temporary captures are outside the repo. Name empty/filled are two states of one screen, reconciling the PDF’s 10 designs with its 9-screen flow. |
| README setup, versions, architecture, offline/motion/auth, assets, gaps/time | Pass | `README.md`, `WALKTHROUGH.md`, this checklist | Documentation reviewed and updated with verified command results; time was not tracked and is explicitly not estimated. |
| Android release APK / iOS Simulator `.app` | Pass | `build/app/outputs/flutter-apk/app-release.apk`, `build/jdonuts-ios-simulator-current.zip` | Current APK build passed (arm64, 32.3 MB) and `apksigner` verified its v2 signature. `flutter build ios --simulator` and ZIP integrity check passed. Simulator artifact is Debug because Flutter rejects Release Simulator builds. |
| 2–4 minute local screen recording of the current UI | Partial | `build/jdonuts-demo-walkthrough.mov` | A 211-second walkthrough exists, but predates the final visual pass. A fresh recording was not verified. No upload or submission occurred. |

## Optional recommendations and bonuses from the PDF

These are not mandatory for the local app slice and are not counted as required failures.

| Optional item | Status | Note |
|---|---|---|
| Mock server with versioned endpoints/envelope | Not implemented | PDF says backend is optional. No server means no Dio/API envelope is required. |
| Persistent cart | Not implemented | PDF labels persistence a bonus; Add to cart gives visual feedback. |
| Burmese localization | Not implemented | PDF labels another locale a bonus; English ARB is generated with gen-l10n. |
| CI workflow | Not implemented | PDF lists CI as optional. |
| Non-Home/Rewards bottom tabs | Implemented as allowed | PDF explicitly allows simple placeholders for the other three destinations. |

## User constraints

No public repository, upload, email, external submission, or client screenshot/PDF commit was made. Local build artifacts and docs remain in the workspace only.
