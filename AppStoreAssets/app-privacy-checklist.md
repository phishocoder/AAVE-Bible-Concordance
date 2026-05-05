# App Privacy Checklist

Prepared from the current iOS repo for **AAVE Bible Concordance**.

## How to use this
This is a conservative prep sheet for the App Store Connect `App Privacy` section. It is not legal advice. Review the final release build and the actual enabled backend configs before entering answers.

## Summary view

| Feature / SDK | Evidence in repo | Data involved | Linked to user? | Tracking? | Suggested disclosure angle |
|---|---|---|---|---|---|
| Firebase Analytics | App target links `FirebaseAnalytics` | Usage, diagnostics, device/app interaction data | Potentially yes at provider level | No clear ad tracking evidence found | `Analytics` / `Usage Data` / possibly `Diagnostics` |
| Firebase Auth (anonymous) | `ContentView` + `FirebaseAuthManager` | Anonymous user ID | Yes, persistent app account ID | No evidence of ad tracking | `Identifiers` |
| Sign in with Apple via Firebase | `AppleAuthManager` | Apple auth identity data, possible name/email from Apple auth flow | Yes | No evidence of ad tracking | `Contact Info` and `Identifiers` only if actually retained/used |
| Firestore users collection | `AppleAuthManager`, `UsernamePromptView`, `UserDirectory` | Display name, createdAt, lastActiveAt, uid | Yes | No | `User Content` / `Identifiers` |
| Firestore quizScores collection | `QuizScoreLogger`, `LeaderboardViewModel` | userID, score, username, timestamp, weekly ranking fields | Yes | No | `User Content`, `Identifiers`, `Usage Data` |
| Firebase Messaging / push | `AppDelegate`, `NotificationManager` | Push token, notification preferences, engagement | Potentially yes | No | `Identifiers` and maybe `Usage Data` |
| Local bookmarks | `Bookmarks.swift` | Saved verses and verse text | Stored on device | No | Usually not App Privacy if kept only on device and not sent off-device |
| Local notes | `UserDataManager.swift` | Verse notes entered by user | Stored on device | No | Usually not App Privacy if kept only on device and not sent off-device |
| Local reading history / progress / prefs | `UserDataManager`, `UserProfilePreferences`, `NotificationManager` | Reading history, streaks, preferences, onboarding state | Stored on device | No | Usually not App Privacy if only local |

## Detailed checklist

### 1. Firebase Analytics
- Evidence:
  - App target includes `FirebaseAnalytics`
  - Docs call out Firebase Analytics
- Data that may be collected:
  - App usage
  - Device/app interaction data
  - Session metrics or events
- Linked to identity:
  - **Potentially yes**, depending on provider-side association
- Used for tracking:
  - **No evidence found** of third-party ad tracking or cross-app advertising use
- Suggested App Store disclosure:
  - `Usage Data`
  - `Analytics`
  - Possibly `Diagnostics` if your release setup uses it that way

### 2. Firebase Authentication
- Evidence:
  - Anonymous auth on app init
  - Sign in with Apple through Firebase
- Data that may be collected:
  - Firebase user ID
  - Authentication metadata
  - Apple sign-in identity data required for auth flow
- Linked to identity:
  - **Yes**
- Used for tracking:
  - **No evidence found**
- Suggested disclosure:
  - `Identifiers`
  - Possibly `Contact Info` if Apple-provided name/email is retained in practice

### 3. Firestore account profile data
- Evidence:
  - `users` documents store `displayName`, `createdAt`, `lastActiveAt`
- Data that may be collected:
  - Display name / first name
  - User ID
  - Account activity timestamps
- Linked to identity:
  - **Yes**
- Used for tracking:
  - **No**
- Suggested disclosure:
  - `User Content`
  - `Identifiers`

### 4. Firestore leaderboard and quiz data
- Evidence:
  - `quizScores` collection
- Data that may be collected:
  - Quiz scores
  - Display name shown on leaderboard
  - User ID
  - Timestamps and weekly leaderboard grouping
- Linked to identity:
  - **Yes**
- Used for tracking:
  - **No**
- Suggested disclosure:
  - `User Content`
  - `Identifiers`
  - Possibly `Usage Data`

### 5. Push notifications / Firebase Messaging
- Evidence:
  - Notification permission request
  - APNs registration
  - FCM token handling
- Data that may be collected:
  - Push token / FCM token
  - Notification settings / delivery data
- Linked to identity:
  - **Potentially yes**
- Used for tracking:
  - **No evidence found**
- Suggested disclosure:
  - `Identifiers`
  - Possibly `Usage Data`

### 6. Bookmarks, notes, history, streaks, preferences
- Evidence:
  - Stored in `UserDefaults` or local models
- Data that may be collected:
  - Saved verses
  - Notes
  - Reading history
  - Progress and settings
- Linked to identity:
  - Local only in repo evidence
- Used for tracking:
  - **No**
- Suggested disclosure:
  - If this data stays on device only, it may not need App Privacy disclosure as collected data

## Important manual confirmations before you fill App Privacy
1. Confirm whether any **email address from Sign in with Apple** is retained or exposed by backend config, because the app code does not visibly store it in Firestore.
2. Confirm whether Firebase Analytics events are standard SDK-only or include custom user-linked fields.
3. Confirm whether any support or feedback channel outside the app collects contact info that should be reflected in the public privacy policy.

## Conservative App Store entry posture
If you want the safest honest posture:
- Disclose Firebase-backed auth/account identifiers
- Disclose leaderboard display name and quiz score data
- Disclose notification token usage
- Disclose analytics telemetry if Firebase Analytics is active in production
- Do **not** claim `No data collected` for this app
