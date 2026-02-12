# AAVE Bible App

## Vision
AAVE Bible App exists to help people encounter Scripture in language that feels natural, clear, and spiritually serious.

This is not a novelty translation project. It is a reading and discipleship product built to make Scripture and commentary more accessible without flattening theology or turning faith into entertainment.

## Product In Plain Language
The app helps someone:
- Open the Bible quickly
- Read in AAVE (with optional traditional comparison)
- Understand context through commentary
- Build a daily rhythm through small, repeatable actions

Core loop:
`Open app -> read -> reflect -> save/share -> return tomorrow`

## Core Principles
- Cultural fluency without caricature
- Theological clarity over trend language
- Devotional utility over gimmicks
- Offline-first reliability where possible
- Small, testable feature changes

## Architecture Decisions
### 1) SwiftUI + Service-Singleton Pattern
The app primarily uses SwiftUI views backed by shared service/view model singletons (for example `ReadingProgressService.shared`, `NotificationManager.shared`).

Why:
- Keeps state predictable for a small team
- Fast iteration with minimal wiring
- Works well for app-wide settings and progress state

Tradeoff:
- Requires discipline around side effects and test seams

### 2) Local-First Content + State
Primary Scripture/commentary resources are bundled JSON under:
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Resources/Books`
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Resources/Commentary`

Most behavior and personalization state is persisted in local app storage (`UserDefaults` / local models).

Why:
- Reliable reading experience even with poor connectivity
- Lower privacy risk
- Fast startup and deterministic behavior

### 3) Thin Remote Integrations
Firebase is used for scoped needs (auth, messaging, quiz leaderboard logging) rather than as the core reading dependency.

Why:
- Keep Bible reading path resilient and available
- Reduce operational complexity

### 4) Deterministic Personalization (No ML)
Personalization uses local-only rules based on:
- Reading history
- Book frequency
- Time-of-day usage

Why:
- Privacy-safe
- Explainable and debuggable
- Works fully offline

## Repo Map
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views` - UI screens and view composition
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views/Services` - app services and shared state
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Models` - core data models and Bible metadata
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Resources` - bundled Scripture/commentary content
- `/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Docs` - product and engineering docs

## Local Setup
1. Open project in Xcode.
2. Ensure local Firebase config is present if needed for auth/leaderboard features.
3. Build and run on simulator/device.

Build command:
```bash
cd /Users/philshobo/Documents/Projects/AAVE-Bible-Concordance
xcodebuild -project "AAVE Bible Concordance.xcodeproj" -scheme "AAVE Bible Concordance" -destination 'generic/platform=iOS' build
```

## Non-Goals (Explicit)
These are intentionally out of scope unless product direction changes:
- Social feed mechanics
- Chat/community moderation systems
- Belief profiling or inference
- ML-driven spiritual recommendations
- Gamification that overwhelms Scripture engagement
- Meme-style or parody scripture voice

## Cultural + Theological Guardrails (Do Not Break)
### Scripture Text
- Must feel timeless, not slang-chasing
- Must not read like parody
- Must not insert jokes
- Must preserve doctrinal meaning and narrative seriousness

### Commentary
- Can be modern and conversational
- Emojis are acceptable in commentary only
- Must still preserve theological clarity
- Should guide, not grandstand

### Voice Integrity
- AAVE expression should be intentional and respectful
- Avoid exaggerated spellings/phrasing that make the text performative
- If a line sounds like a skit, rewrite it

## Contribution Guidelines
Before coding, lock:
- Goal
- Scope (in/out)
- Constraints
- Acceptance criteria

While coding:
- Make small, reviewable changes
- Follow existing architecture patterns
- Add guardrails for error handling and defaults
- Run build/tests after meaningful changes

When done, report:
- What changed
- Files touched
- How to verify
- Risks/follow-ups

## Quality Checklist For New Features
- Does it reduce cognitive load?
- Does it increase repeat daily use?
- Does it preserve cultural and theological integrity?
- Does it work offline or degrade gracefully?
- Is behavior explainable without hidden model logic?

## License
TBD
