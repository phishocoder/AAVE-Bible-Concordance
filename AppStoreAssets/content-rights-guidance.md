# Content Rights Guidance

Prepared for **AAVE Bible Concordance**

## High-level answer prep
This app appears to include a mix of:
- Original AAVE Bible project content and commentary created for the app
- Third-party traditional Bible translation access, especially **NET Bible** content
- Standard Apple system assets and app-owned branding assets

## What looks original to this app
Likely first-party / app-owned material:
- Bundled AAVE translation JSON files under `Resources/Books/**`
- Bundled commentary JSON files under `Resources/Commentary/**`
- App UI copy, quiz framing, leaderboard text, and product design
- App name, brand, and logo assets, assuming you created them

## What clearly needs rights review
### 1. NET Bible / traditional translation access
Evidence:
- `CreditsView.swift` explicitly credits `NET Bible`
- `BibleAPIService.swift` fetches traditional translations
- `APIConfig.swift` points to `https://labs.bible.org/api`
- Multiple views label traditional text as `NET Translation`

Why this matters:
- The app displays or accesses third-party Bible translation content.
- You should confirm the rights, attribution, API terms, and redistribution/screenshot use permissions for NET Bible / labs.bible.org content.

### 2. Any non-original imagery or brand assets
I did not find a clean rights manifest for all bundled image assets in this pass.

Human confirmation needed:
- Confirm app icon, logo marks, launch art, and any bundled images are original, properly licensed, or otherwise cleared.

## Files that should be reviewed before answering Content Rights
- [Views/CreditsView.swift](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views/CreditsView.swift)
- [Views/Services/BibleAPIService.swift](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views/Services/BibleAPIService.swift)
- [Views/Services/APIConfig.swift](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views/Services/APIConfig.swift)
- [Views/Services/VerseManager.swift](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Views/Services/VerseManager.swift)
- [Docs/TECH_STACK.md](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Docs/TECH_STACK.md)
- [Resources/Books](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Resources/Books)
- [Resources/Commentary](/Users/philshobo/Documents/Projects/AAVE-Bible-Concordance/Resources/Commentary)

## Recommended manual answer direction
### If you have documented rights/permission for NET Bible access and use
You can answer in a way that says:
- the app contains original content created for this product
- the app also accesses third-party Bible translation content with proper attribution/permission

### If you have not yet verified NET Bible / labs.bible.org rights
Do **not** claim all content rights are fully original and clear.

Safer temporary position:
- confirm first-party ownership of AAVE/commentary content
- separately verify third-party translation rights before final App Store submission

## What I would not claim yet
I would **not** state the following without human verification:
- that all Bible text in the app is original
- that all third-party translation licenses are fully cleared
- that all external content usage terms permit every current use case

## Manual conclusion
Most likely answer:
- **This app includes both original content and third-party translation content that must be properly attributed and rights-cleared.**

Primary blocker remaining:
- confirm the exact rights posture for **NET Bible / labs.bible.org** usage before finalizing `Content Rights Information` in App Store Connect
