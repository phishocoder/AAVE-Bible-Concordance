# AAVE FS Demo – FullStory Mobile Specialist Challenge

This repo contains a minimal iOS SwiftUI demo used to validate the FullStory iOS SDK:
- **Privacy Rules**: masked and excluded fields; unmasked safe CTAs.
- **Identity**: `FS.identify()` with custom properties.
- **Pages**: `FS.page()` for logical journeys.
- **Events**: `FS.event()` for key actions.

## Build
- Xcode 15+ / iOS 17+ (tested on device)
- Uses Swift Package Manager (no CocoaPods)
- FullStory Org ID is **not** committed. Build uses a generated `FullStory.json` (CLI) at runtime.

### Setup (reviewer)
1. Open `AAVE Bible Concordance.xcodeproj`.
2. Select scheme: **AAVE FS Demo**.
3. Ensure the FullStory SPM is resolved (Xcode will fetch).
4. Place a **placeholder** `FullStory.json` if you don’t have the CLI:
   - Create `AAVE FS Demo/FullStory.json` with `{ "OrgId": "o-xxxxxx", "SwiftUI": { "Enabled": true, "SelectorVersion": 3, "SelectorPreview": 2 } }`
   - Or run the FullStory CLI and copy the generated file into the app bundle.
5. Run on a physical device for best results.

## Where to look
- `AAVE_FS_DemoApp.swift` – demo wiring.
- `FullStory/FSPrivacyDemo.swift` – sample fields for masking/excluding.
- `FullStory/FSIdentityAndEvents.swift` – `FS.identify`, `FS.page`, `FS.event`.
- `FullStory/FSDiagnostics.swift` – logs env and JSON presence.

## Security / Secrets
- `FullStory.json` and `GoogleService-Info.plist` are **intentionally ignored** and must never be committed.
