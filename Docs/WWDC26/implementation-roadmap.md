# WWDC26 Implementation Roadmap

## Executive Recommendation

Prepare the app for iOS 27, but do not make iOS 27 the minimum deployment target yet.
Build a small intelligence layer that:

1. Retrieves Scripture and commentary from the app's bundled content.
2. Uses Apple Foundation Models only to summarize, classify, or structure that content.
3. Returns citations to exact Bible references.
4. Falls back to existing search and commentary when Apple Intelligence is unavailable.

This preserves the app's offline-first architecture, keeps marginal AI cost near zero, and
reduces the theological risk of generated content being mistaken for Scripture.

## What Apple Announced

### High relevance to this app

| Time | Announcement | Product relevance |
| --- | --- | --- |
| 02:23 | New Apple Foundation Models, adapted for on-device and Private Cloud Compute use | Low-cost text understanding and generation |
| 02:56 | Foundation Models adds image input and server-model support | OCR and image-to-passage workflows; optional complex queries |
| 03:20 | Eligible small developers can use Apple models on Private Cloud Compute without cloud API charges | Potential no-API-cost escalation path |
| 06:44 | Multimodal text and image prompts | Recognize a printed verse, study page, or screenshot |
| 07:00 | Vision tools such as OCR can be used with the model on device | Extract exact text before asking the model to interpret it |
| 08:29 | Open-source package with skills and context-management utilities | Reusable study modes and bounded context |
| 09:04 | Dynamic Profiles can swap models, tools, and instructions in one session | Devotional, context, and study modes without separate chat systems |
| 12:00 | Evaluations framework, improved Instruments, and an `fm` command-line tool | Test prompts before shipping |
| 12:26 | Private app RAG tool powered by Core Spotlight | Ground natural-language search in bundled Scripture |
| 13:13 | Core AI for running custom models on device | Future option, not an MVP requirement |
| 14:45 | App Intents connects app content and actions to Siri AI | Open, find, save, and continue Scripture by voice |
| 15:21 | Entity and intent schemas | Make verses and app actions understandable to the system |
| 16:27 | View Annotations exposes on-screen entities to Siri | Commands such as "bookmark this verse" |
| 19:14 | Natural-language access and semantic search through Siri | New discovery and re-engagement paths |
| 25:45 | iOS apps become resizable on iPad and through iPhone Mirroring | Reader and search layouts need width-independent behavior |
| 29:12 | Reorderable containers | Optional ordering for saved study collections |
| 29:59 | Swipe actions in any SwiftUI container | Cleaner bookmark, note, and highlight actions |
| 30:18 | Improved text selection | Better copying and sharing in the reader |
| 32:33 | Adaptive toolbar priorities and overflow behavior | Improve the existing reader toolbar at narrow widths |
| 41:13 | Recompiling with Xcode 27 adopts the current Liquid Glass design | Requires a visual regression pass |
| 46:32 | Faster, simpler Xcode Cloud setup | Useful future CI path |
| 47:13 | Preview variants for arbitrary state | Efficient testing of loading, empty, error, and AI availability states |
| 49:23 | Deeper agentic coding in Xcode 27 | Development workflow improvement, not an app feature |

### Important cost qualification

On-device Foundation Models have no per-token API bill. Private Cloud Compute access without
cloud API cost is not universal: Apple's current requirements include App Store Small Business
Program enrollment, fewer than two million first-time downloads, and a PCC entitlement. The app
must not depend on PCC until eligibility and entitlement approval are confirmed.

## Current App Fit

The repository already has strong foundations for this approach:

- SwiftUI application with shared service singletons.
- Bundled AAVE Scripture and commentary under `Resources`.
- Local search in `TranslationService` and `VerseManager`.
- Stable `VerseReference` and `SearchResult` models.
- Existing notes, bookmarks, highlights, reading progress, and deep-link routing.
- Firebase Analytics is linked, so aggregate feature telemetry can use the existing dependency.
- A Live Activities App Intent exists, but it is still the generated example and is not a
  Scripture action surface.

Important preparation issues:

- The active project file still contains an iOS 18.2 deployment target, despite
  `Docs/TECH_STACK.md` saying iOS 26.0. Confirm the intended support floor before implementation.
- AI APIs must be isolated behind availability checks rather than spread through SwiftUI views.
- Existing search is primarily lexical/reference based. It is the correct retrieval fallback,
  but it is not yet a semantic retrieval layer.
- Navigation currently has both `NavigationRouter` and older notification/singleton paths.
  App Intent handoff should use one explicit route, preferably `NavigationRouter`.

## Ranked Feature Plan

### P0: Platform and AI foundation

**User value:** None directly, but every AI feature becomes testable, replaceable, and safe.

Add:

- `IntelligenceService` protocol.
- `AppleIntelligenceService` implementation guarded with `#available`.
- `IntelligenceAvailability` states:
  `available`, `deviceNotEligible`, `notEnabled`, `modelNotReady`, and `unsupported`.
- A deterministic fallback that returns existing commentary/search results.
- Structured response types rather than parsing free-form model text.
- Prompt versioning and fixture-based evaluation cases.
- A feature flag so AI UI can ship disabled while Xcode 27 APIs stabilize.

Do not raise the deployment target solely for AI. Compile new APIs conditionally and keep the
core reader available to every currently supported device.

### P1: "Study This Passage" on device

**Lean MVP:** Add one action to a verse or selected passage that returns:

- Plain-language summary
- Historical/literary context from bundled commentary
- Two reflection questions
- Exact source references

**Implementation shape:**

1. User selects one verse or a short passage.
2. App retrieves the canonical AAVE text and bundled commentary.
3. Foundation Models produces a guided `StudyGuide` structure.
4. UI clearly labels the output "AI-assisted study notes."
5. Every answer displays the source passage and a "Read in context" action.

**Fallback:** Show existing commentary and deterministic reflection prompts.

**Why first:** It uses content already loaded in memory, stays within the model context window,
works offline on eligible devices, and adds clear value without requiring a new index.

**Success metric:** Percentage of generated guides followed by "Read in context," note creation,
or bookmark actions.

### P1: Scripture-aware natural-language search

Example queries:

- "Verses about being anxious when I cannot sleep"
- "Where does Jesus talk about loving enemies?"
- "Show passages about wisdom and money"

**Architecture:**

1. Parse direct references with the existing `SearchQueryParser`.
2. Retrieve candidates from local search/Core Spotlight.
3. Give only those candidates to the model.
4. Ask the model to rank and explain relevance using structured output.
5. Reject any generated citation that is not present in the retrieved candidate set.

For iOS 27, evaluate Apple's private Core Spotlight RAG tool. Until that API is stable, retain
the current lexical search and add normalized tags/synonyms as the fallback.

**Critical rule:** The model must never create verse text or references from memory.

**Success metric:** Search-result opens per natural-language query and the rate of zero-result
queries.

### P1: Siri, Spotlight, Shortcuts, and Action button

Start with a narrow system surface:

- `OpenVerseIntent`
- `ContinueReadingIntent`
- `FindPassageIntent`
- `BookmarkVerseIntent`
- `VerseEntity`
- `BibleBookEntity`
- `AppShortcutsProvider`

Use the existing `VerseReference` as the domain model and create a smaller, display-friendly
`VerseEntity` for system use. Open-style intents should hand off through one
`NavigationRouter` deep-link path. Bookmarking can complete inline when the reference resolves.

Index user-relevant content, not the entire internal model graph:

- Recently read passages
- Bookmarks
- Highlights
- Notes, only with explicit privacy review
- Optionally all bundled verses for semantic discovery

**Privacy default:** Do not index private note text into system search in the first release.

**Success metric:** Intent completions, Spotlight opens, and seven-day return rate after an
intent-driven session.

### P2: Ask about the current passage

Provide bounded question types rather than launching an unrestricted spiritual chatbot:

- "What does this phrase mean?"
- "Who is speaking and to whom?"
- "What happened immediately before this?"
- "How does the AAVE wording compare with the selected traditional translation?"
- "Give me three observation questions."

Use Dynamic Profiles for study modes only after the P1 flow is reliable:

- `context`
- `devotional`
- `compareTranslations`
- `reflection`

All profiles should share the same retrieval tools and citation validator.

**Security/privacy gotcha:** Treat user notes and imported text as untrusted prompt content.
Never place it in model instructions. Do not log prompts or generated spiritual questions to
Firebase.

### P2: Camera or screenshot to Scripture

Flow:

1. User selects a screenshot or photographs a printed passage.
2. Vision OCR extracts text on device.
3. Existing reference parsing identifies a likely verse.
4. The app shows candidates for confirmation.
5. The user opens the passage, compares translations, or creates a study guide.

This should be a confirmation-based retrieval workflow, not automatic theological analysis of
an image.

**Success metric:** Confirmed passage matches divided by scan attempts.

### P3: Optional Private Cloud Compute escalation

Use PCC only for questions that are too complex for the on-device model, and only after:

- Small Business Program eligibility is confirmed.
- The PCC entitlement is approved.
- Daily access and iCloud+ behavior are acceptable for the product.
- A no-PCC fallback exists.
- The UI explains when processing leaves the device for Private Cloud Compute.

Potential uses:

- Multi-chapter synthesis
- Longer study-plan generation
- Comparing several retrieved passages and commentary sections

Do not make PCC the default for single-passage study.

### P3: Custom on-device model with Core AI

Defer this. A custom embedding, classification, or retrieval model may eventually improve
AAVE-specific semantic search, but it adds conversion, evaluation, app-size, memory, and device
performance work. Apple's built-in model plus deterministic retrieval should be tested first.

### Future Backlog: Personalized Verse Image Backgrounds

When stable iOS 27 image-generation or Apple Intelligence creative APIs are available, evaluate
an opt-in enhancement to the existing verse image feature that generates decorative backgrounds.
This is a future feature and is not part of Milestone 1.

- Gate the feature to iOS 27 or later and require explicit API/device availability checks.
- Keep verse text sourced exclusively from bundled app Scripture data; generated output may only
  provide the decorative background.
- Do not generate Scripture, doctrine, or factual imagery depicting God, Jesus, angels, demons,
  or biblical events.
- Do not use private notes, prayer text, reading history, or sensitive spiritual topics in image
  prompts unless the user explicitly opts in.
- Require the user to choose or confirm the visual direction before generation.
- Measure success primarily by completed verse-image exports and shares.

## Features Not Recommended

- Generating or rewriting missing Scripture with an LLM.
- Presenting generated text in the same typography or treatment as Scripture.
- An unrestricted "AI pastor" or counseling chatbot.
- Personalized spiritual or belief profiling.
- Sending notes, prayer text, or reading history to third-party models by default.
- Training a custom Core AI model before retrieval quality is measured.
- Replacing exact reference search with probabilistic AI search.

## Proposed Architecture

```text
SwiftUI feature
    |
    v
IntelligenceService
    |
    +-- AvailabilityPolicy
    +-- PassageContextBuilder
    +-- CitationValidator
    +-- TelemetryRecorder
    |
    +-- Apple on-device Foundation Models
    +-- Optional Private Cloud Compute
    +-- Deterministic fallback
            |
            +-- TranslationService
            +-- VerseManager
            +-- Bundled commentary
            +-- Core Spotlight index
```

### Suggested file boundaries

- `Views/Services/Intelligence/IntelligenceService.swift`
- `Views/Services/Intelligence/AppleIntelligenceService.swift`
- `Views/Services/Intelligence/PassageContextBuilder.swift`
- `Views/Services/Intelligence/CitationValidator.swift`
- `Models/StudyGuide.swift`
- `Models/IntelligenceAvailability.swift`
- `Views/StudyGuideView.swift`
- `AppIntents/VerseEntity.swift`
- `AppIntents/OpenVerseIntent.swift`
- `AppIntents/ContinueReadingIntent.swift`
- `AppIntents/BookmarkVerseIntent.swift`
- `AppIntents/AAVEBibleShortcuts.swift`

Keep intent and AI types thin. Existing services should remain responsible for Scripture,
bookmarks, notes, and navigation.

## Required AI Guardrails

1. Scripture text always comes from app data, never model output.
2. Generated output is visibly labeled.
3. Every factual passage claim links to one or more retrieved references.
4. Invalid or unverified references are removed before display.
5. The model receives only the minimum passage/context required.
6. User notes are opt-in context and are never analytics payloads.
7. Sensitive-topic guardrail failures produce a respectful, non-generative fallback.
8. The app does not present AI output as pastoral, medical, legal, or crisis counseling.
9. Prompt and output tests include doctrinal distortion, fabricated citations, AAVE caricature,
   prompt injection, and unsupported-device cases.

## UI States to Design

Every intelligence feature needs:

- Ready
- Generating
- Success
- Cancelled
- Model unavailable
- Apple Intelligence disabled
- Model downloading/not ready
- Unsupported language or locale
- Context too large
- Guardrail refusal
- No grounded sources
- Offline fallback

The non-AI path should remain useful, not look like an error screen.

## Telemetry

Use aggregate events only:

- `study_guide_requested`
- `study_guide_completed`
- `study_guide_fallback_used`
- `study_guide_source_opened`
- `study_guide_saved_to_notes`
- `semantic_search_submitted`
- `semantic_search_result_opened`
- `app_intent_completed`
- `ai_output_helpful`
- `ai_output_not_helpful`

Properties may include availability state, latency bucket, result count, and feature version.
Do not include verse text, notes, search text, generated output, or personal spiritual topics.

## Delivery Sequence

### Milestone 0: One week - compatibility spike

- Install Xcode 27 beta alongside the current stable Xcode.
- Confirm the actual deployment target policy.
- Build the current app without changing behavior.
- Prototype `SystemLanguageModel` availability behind a service.
- Request/verify PCC entitlement separately; do not block the milestone on it.
- Measure one-verse and one-passage latency on eligible hardware.

**Exit:** A hidden debug screen reports model availability and can generate a structured,
source-grounded study guide from a fixed passage.

### Milestone 1: One to two weeks - Study This Passage

- Add production service abstraction and structured `StudyGuide`.
- Add retrieval and citation validation.
- Add loading/error/fallback UI.
- Add prompt fixtures and output evaluations.
- Add privacy-safe telemetry.

**Exit:** The feature works on-device when available and shows existing commentary otherwise.

### Milestone 2: One to two weeks - system integration

- Add verse/book entities.
- Add open, continue, find, and bookmark intents.
- Index recent and saved Scripture in Spotlight.
- Route all open intents through `NavigationRouter`.
- Test Siri, Shortcuts, Spotlight, widgets, and Action button.

**Exit:** Users can open or save a verse outside the app with reliable handoff.

### Milestone 3: Two weeks - grounded natural-language search

- Build or adopt the private Core Spotlight retrieval index.
- Add candidate ranking and citation validation.
- Add semantic-search UI mode with deterministic fallback.
- Evaluate against a curated query set.

**Exit:** Search improves discovery without fabricated references.

### Milestone 4: Later - multimodal and PCC

- Add OCR-based passage recognition.
- Add bounded current-passage questions.
- Evaluate Dynamic Profiles.
- Add PCC only if eligibility, quotas, privacy UX, and reliability are acceptable.

## Acceptance Criteria for the First Shippable AI Feature

- Builds with the selected Xcode 27 SDK.
- Existing supported-device reader still works.
- No external AI API key or per-token vendor account is required.
- Scripture text is never generated.
- Every generated guide contains validated source references.
- Unsupported devices receive useful commentary/search fallback.
- Loading, cancellation, error, and guardrail states are covered.
- Unit tests cover citation validation and fallback selection.
- Prompt evaluations cover at least 25 representative passages and adversarial inputs.
- Analytics contain no Scripture text, note text, prompt text, or generated output.
- VoiceOver, Dynamic Type, reduced transparency, and increased contrast are verified.
- Reader/search UI is tested at resizable iOS widths.

## Official References

- [Platforms State of the Union](https://developer.apple.com/videos/play/wwdc2026/102/)
- [Foundation Models](https://developer.apple.com/documentation/foundationmodels)
- [Generating content with Foundation Models](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models)
- [Private Cloud Compute developer access](https://developer.apple.com/private-cloud-compute/)
- [Apple Intelligence for developers](https://developer.apple.com/apple-intelligence/)
- [Foundation Models acceptable use requirements](https://developer.apple.com/apple-intelligence/acceptable-use-requirements-for-the-foundation-models-framework/)
- [App Intents](https://developer.apple.com/documentation/appintents)
