# AAVE Bible App

A Bible reading experience built with a culturally fluent AAVE translation + commentary layer designed for clarity, voice, and real-life application.

## What this repo contains
- iOS app source
- Documentation-first “canonical docs” in `/Docs` used to keep AI + humans aligned
- Content pipeline notes for translation/commentary (see `Docs/PRD.md`)

## Quick Start
1) Clone repo
2) Open the Xcode project/workspace in Xcode
3) Configure environment/secrets (see “Environment”)
4) Build + run on iPhone simulator

## Environment
- **Never commit secrets**.
- Firebase config:
  - `GoogleService-Info.plist` (not committed)
- FullStory config (if using FullStory integration):
  - `AAVE FS Demo/FullStory.json` generated via `Tools/FullStoryCommandLine`

## Product summary
- Primary audience: everyday believers who want clear reading + commentary
- Secondary audience: study-minded users who want search, highlights, notes

## Core loop (MVP)
Open app → pick book/chapter → read AAVE translation → tap into commentary → save/bookmark/share → return tomorrow

## Screens & flows (MVP)
- Screens: Home/Books, Chapter list, Reader, Verse detail (optional), Commentary, Search, Bookmarks, Settings
- Flows: Browse and read, Search and open result, Bookmark and view list, Settings adjustments, Offline behavior (if supported)

## MVP features
- Bible navigation (book/chapter/verse)
- Reading view (AAVE translation)
- Commentary view (emoji allowed here, per rules)
- Search (book/chapter keyword at minimum)
- Bookmarks / highlights (at minimum bookmarks)
- Settings (text size, theme, maybe offline toggles)

## Data sources
- Local bundled JSON for AAVE translation + commentary (`Resources/Books/**`, `Resources/Commentary/**`)
- Remote translation fetches via `https://labs.bible.org/api`

## Documentation system (source of truth)
- `CODEX.md` — Operating rules for contributors and AI
- `progress.md` — Current step, status, known issues
- `/Docs/PRD.md` — Product requirements
- `/Docs/APP_FLOW.md` — Screen inventory + navigation paths
- `/Docs/TECH_STACK.md` — Versions, dependencies, services
- `/Docs/FRONTEND_GUIDELINES.md` — UI tokens and rules
- `/Docs/BACKEND_STRUCTURE.md` — Data contracts and APIs
- `/Docs/IMPLEMENTATION_PLAN.md` — Incremental build plan
- `/Docs/LESSONS.md` — Decisions and rules learned

## Contributing
- Work in small slices
- Update `progress.md` and relevant docs when behavior changes
- Follow `CODEX.md` rules

## License
(TBD)
