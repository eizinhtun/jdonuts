# J’Donuts Code Test Requirements

Checklist based on the attached 15-page PDF. The reference PDF/screens are not copied into this repository.

## Authentication
- [ ] Onboarding → phone → OTP → name → DOB → welcome → home; returning login → home.
- [ ] Fake repository latency, duplicate-request guard, loading and inline failure.
- [ ] Pure phone/name/DOB validators; OTP 123456, six-digit paste/autofill/backspace, shake/clear, three-strike lock and 5-minute resend.
- [ ] Preserve values on back; unknown numbers can register; session restore/logout; honest social/legal placeholders.

## Offline Home and Product
- [ ] Seed bundled JSON to local versioned database; UI reads repository/database data.
- [ ] One shared member record; header, banners, Seasonal, Popular, Order again, four shops, notification badge.
- [ ] Product route/detail, image, code/new/description/MMK, quantity and live total.
- [ ] Local image assets, image failure/placeholder, section loading/empty/error/retry.
- [ ] Connectivity/reachability signal, background reconnection refresh and pull-to-refresh.

## Rewards and motion
- [ ] Shared member points/tier; animated points ring, tier ladder, tabs, challenge cards/art, badge, bottom nav.
- [ ] Onboarding/registration/welcome/home/product transitions and control feedback.
- [ ] Reduce Motion support, cleanup controllers/timers, portrait and text-scale layouts.

## Architecture and delivery
- [ ] Feature-first presentation/domain/data; domain has no Flutter imports; typed failures/results and immutable data.
- [ ] Riverpod DI/state, go_router auth guard and `/product/:id`.
- [ ] ARB/gen-l10n, centralized theme/motion tokens, database migration, secure session.
- [ ] Unit, widget, integration coverage; `dart format`, `flutter analyze`, `flutter test`.
- [ ] README, walkthrough, Android release APK, iOS simulator app/archive where tooling allows.

## Audit status (2026-11-10)

- Implemented in source: visual auth steps, pure phone/OTP/name/DOB validators, bundled JSON data and original SVGs, Home/product/rewards screens, shared member mock data, named theme/motion tokens, feature folders, README and walkthrough.
- Verified: `dart format --set-exit-if-changed lib test integration_test`; `flutter test --no-pub test/domain/validators_test.dart` (11 passing); `git diff --check`.
- Blocked/unverified: pub dependency resolution stalled downloading large package archives (measured ~44 KB/s). The existing lock/package config does not include the newly declared dependencies. Therefore whole-app analyzer, widget tests, app builds, integration flow, Drift/session persistence, Riverpod/go_router runtime behavior and platform artifacts are not verified.
