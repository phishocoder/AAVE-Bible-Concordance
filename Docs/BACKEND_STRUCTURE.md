# BACKEND_STRUCTURE — Data Contracts & Storage

## Data models
- Book { id, name, testament, order }
- Chapter { bookId, number, verses[] }
- Verse { id, number, textAAVE }
- Commentary { id, bookId, chapter, rangeStart, rangeEnd, body, takeaways[] }

## Storage
- Local content bundled as JSON:
  - `Resources/Books/**`
  - `Resources/Commentary/**`
- UserDefaults for:
  - Bookmarks, highlights, reading progress, onboarding flags, preferences
- Search index strategy: Not found (TBD)

## API (remote translations)
- Base URL: `https://labs.bible.org/api`
- Endpoints (constructed via query string):
  - `GET /?passage={book}+{chapter}:{verse}&type=json&formatting=plain&version={VERSION}`
  - `GET /?passage={book}+{chapter}&type=json&formatting=plain&version={VERSION}`

## Firebase services
- Auth (anonymous + Apple sign-in via FirebaseAuth)
- Firestore (leaderboards, quiz scores, usernames)
- Messaging (push notifications)
- Analytics (FirebaseAnalytics)

## Caching & offline behavior
- Local JSON provides offline baseline for AAVE translation.
- Remote fetch caching strategy: Not found (TBD)

## Auth & permissions (if any)
- FirebaseAuth used (anonymous + Apple sign-in)

## Platform notes (TBD)
- iOS data layer notes:
- Android data layer notes:
