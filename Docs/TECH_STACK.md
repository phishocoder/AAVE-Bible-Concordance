# TECH_STACK — Locked Versions & Dependencies

## iOS
- Xcode: 26.0 (user-confirmed daily use)
- Project metadata: `LastUpgradeCheck = 1620` (Xcode 16.2)
- Swift: 5.0 (from project build settings)
- iOS deployment target: 26.0 (user-confirmed) — older 18.2 appears in some targets; confirm if any target should remain 18.2

## Architecture
- UI: SwiftUI
- State management pattern: MVVM-style (ViewModels folder + SwiftUI/Combine usage) — confirm if this is the intended pattern

## Data & Persistence
- Content source:
  - Local bundled JSON in `Resources/Books/**` and `Resources/Commentary/**`
  - Remote API for non-AAVE translations via `https://labs.bible.org/api`
- Persistence:
  - UserDefaults used for settings, bookmarks, progress, and flags
- Search indexing strategy: Not found in repo (TBD)

## Backend / Services (if any)
- API provider / backend: `labs.bible.org` (NET + other remote translations)
- Firebase (via Swift Package Manager, min 11.12.0): Analytics, Auth, Firestore, Messaging, Core
- Auth: FirebaseAuth (incl. Apple sign-in via Firebase)
- Analytics: FirebaseAnalytics
- Crash reporting: Not found in repo (TBD)
- Remote config: Not found in repo (TBD)

## CI / Tooling
- CI provider: Not found in repo (TBD)
- Linting/formatting: Not found in repo (TBD)
- Pre-commit secret guard: `scripts/precommit-secret-scan.sh`

## Platform-specific targets
- Live Activities target present: `AAVEBibleLiveActivities` (WidgetKit + SwiftUI)

## Android readiness (future)
- Shared data contracts format (JSON schema/API contract): TBD
