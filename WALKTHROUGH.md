# Interview walkthrough

## Suggested demo path

1. Start from onboarding. Register with a valid `+95` number and enter demo OTP `123456`.
2. Show name and DOB validation, including Myanmar name support and the 13-year age boundary.
3. Finish registration, enter Welcome, then Home. Home’s member record, offline notice, seeded sections and shops are database-backed.
4. Open a product from a section. Point out the stable route ID/Hero, minimum-one quantity, live MMK total and add feedback.
5. Open Rewards to show the shared member points, animated points ring, tier ladder, Earn/Gift tabs and challenge progress.
6. Open Settings and log out; reopen to exercise session restore and the router guard.

The display language and demo content are English. The backend, live SMS, social providers, legal documents, persistent cart and persisted reward claims are intentionally not simulated as if real.

## Design and architecture choices

- **Database is the local source of truth:** bundled JSON seeds Drift/SQLite on first read in a transaction. Catalog photos are bundled raster assets and the remaining illustrations are SVG. Home, Product and Rewards resolve from the shared local data repository. With no backend, pull-to-refresh or reconnect only reloads SQLite; neither pretends to fetch updates.
- **One member record:** the PDF mock-ups disagree. Home refers to Silver and 500 points to Gold, while Rewards shows the 680,000 points display. The seed uses Silver / 680,000 / 500 remaining and both views consume that record.
- **Riverpod:** providers construct and dispose database, repository, session, reachability, router and draft dependencies. Tests override providers with deterministic delays, clocks/stores/streams. Widgets own only temporary interaction state.
- **Domain boundary:** pure Dart validation, OTP policy and repository contracts do not depend on Flutter. Data adapters own Drift and secure storage. Presentation maps state/errors into localized UI.
- **Session/security:** account profile is stored in local SQLite; secure storage contains the active phone identifier. The sample app has no real secret/token or server authorization.
- **Reachability:** a connectivity interface event triggers a bounded HTTP `generate_204` probe. A Wi-Fi interface is not treated as proof of internet. This is only an online/offline hint for the demo.
- **Assets:** donut, coffee, seasonal-box, and shop-banner photos were generated specifically for this project; the member avatar and Welcome tiles are hand-authored SVGs. No PDF screenshots or external image assets are shipped.
- **Motion:** named tokens unify timing/curves. The rewards ring is custom-painted; tabs and content use a moving indicator/AnimatedSwitcher; shared entrance motion uses staggered delays. Reduce Motion disables repeating/attention loops and settles animated values.

## Likely interview questions

1. **Why use SQLite if the catalog is bundled?** It demonstrates a durable, versioned local source of truth and lets tests prove the app still reads after assets become unavailable. A real sync layer could transactionally upsert server responses without changing screen models.
2. **How would remote refresh work?** Keep SQLite as the rendered source, fetch through a repository sync adapter, validate/version the response, then commit updates transactionally. Preserve the old rows if the request fails.
3. **Why persist only a phone identifier in secure storage?** The fake adapter has no access token. A real service should persist its opaque refresh/session credential and resolve the account on startup; a phone number alone is not authentication proof.
4. **How are resend limits protected?** A shared draft stores an absolute deadline and attempt count across auth subroutes; the repository owns OTP verification. Production enforcement must also happen server-side.
5. **Why is the fake OTP in the client?** This is a test-only local flow, visibly documented in the README. Production OTP codes are server-generated and never embedded in an app.
6. **How do duplicate taps and errors work?** The flow sets a busy state before awaiting repository work; controls disable while busy and typed failures map to inline feedback.
7. **How was age validation tested?** `today` is injectable. Tests cover leap-day and invalid dates, future dates and the exact thirteenth birthday.
8. **What is Reduce Motion?** `MediaQuery.disableAnimations` is read by the shared motion helper and repeating loops. The Rewards widget suite also builds with this flag enabled.

## Current verification and limitations

Refer to `REQUIREMENTS.md` for the evidence-by-requirement audit. The latest full Dart run passed 46 tests with a clean analyzer, including pull-to-refresh. Register → Welcome → Home → Product passed on the iOS Simulator. Android integration could not be rerun in this pass because the Pixel 10 Pro emulator exited with code 1 during startup.

The Android arm64 APK is `build/app/outputs/flutter-apk/app-release.apk` (32.3 MB). Its v2 signature verifies, but the project uses its demo debug signing configuration. The zipped iOS Simulator app is `build/jdonuts-ios-simulator-current.zip`; Flutter supports only Debug mode for Simulator builds. `build/jdonuts-demo-walkthrough.mov` is a 211-second walkthrough from before the final visual changes and should be treated as an older recording; a current recording was not verified.

All ten design states were captured and visually reviewed on the iPhone 17 Pro Simulator after the visual pass. This is a manual comparison, not a pixel-diff sign-off. Generated food/shop photos approximate the reference; Welcome tiles and the member avatar remain vector illustrations. No 60 fps measurement was taken. The integration flow forced the app offline through its connectivity provider; a system airplane-mode toggle was not performed. The PDF and design screenshots remain outside the repository, and no artifact was published or submitted.
