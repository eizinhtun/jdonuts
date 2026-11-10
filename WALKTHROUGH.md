# Interview walkthrough

## How the app is organized

Each feature is grouped under `lib/features/<feature>/`. Domain code holds business rules and interfaces; data adapters implement those interfaces; presentation consumes repositories via Riverpod. Shared result types and design tokens live under `lib/core/`.

## Decisions to explain

- **One member record:** the seed uses Silver, 680,000 points, and 500 remaining to Gold, then feeds both Home and Rewards. This chooses Rewards' points value while retaining the Gold progress copy shared in the Home mock-up.
- **Offline-first:** catalog and illustrations ship with the app. This means the primary screens work in airplane mode from first launch. A production follow-up would store the seed in a versioned Drift database, use its queries as the UI source of truth, then transactionally apply remote refreshes.
- **Fake auth boundary:** `AuthRepository` separates screens from the demo implementation and enforces one-second latency. Replace that adapter with a remote implementation without rewriting validators/screens.
- **Pure validation:** validators can run without Flutter or platform plugins; the name rule uses Unicode letters so Myanmar script is accepted.
- **Motion:** durations and curves are named centrally. Rewards progress is custom-painted; challenge progress uses quarter fills / arcs.

## Likely interview questions

1. **Why keep presentation separate from the domain?** It lets validation and rules run in plain Dart and leaves UI replaceable.
2. **How would you make the database authoritative?** Add Drift tables and migration versions, seed once from bundled JSON, expose watched DAO queries, and update those tables in a transaction after refresh.
3. **How would session restore work?** Persist only a session token/identifier in secure storage; load it before router redirects, then resolve the user from local data or an API.
4. **How do you prevent duplicate auth requests?** The presentation state gates requests while the fake repository returns typed success/failure; server-side idempotency belongs in the eventual API contract.
5. **How would you test age boundaries?** Inject `today`, validate leap/calendar dates, and test the exact 13th birthday and the day before.
6. **How is Reduce Motion handled?** Read `MediaQuery.disableAnimations` and skip durations/looping behavior. Audit every repeating animation when adding more.

## Current limitations

See README known gaps. Package access prevented confirming the requested storage/network adapters, session persistence, analyzer and tests during this pass. Explain that limitation directly rather than describing those pieces as implemented.
