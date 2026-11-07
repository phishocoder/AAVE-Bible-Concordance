# Next release readiness — November 2026

## Target

Correct the reported commentary-reference mismatch and improve reader/action/image layouts at compact and expanded window sizes. Build and validate with public stable Xcode before submission.

## Evidence reviewed

- Google Drive `BUG-REPORT-commentary-mismatch.md`, uploaded November 3, 2026.
- `AAVE-Bible-Bug-Report.zip`: the same report plus `screenshots/deut-24-20-commentary-mismatch.png` and `screenshots/deut-24-21-commentary-mismatch.png`.
- Both screenshots inspected in Drive preview. Deuteronomy 24:20–21 show the correct harvest scripture with unrelated wage-payment commentary. The report also flags chapter 27 without specific additional screenshots.
- Browser downloads did not complete; evidence was read through Drive's preview. No claim of a saved local ZIP.

## Cause and changes

- `TranslationService` already retrieves exact book/chapter/verse keys. Generated teaching paragraphs in Deuteronomy were instead numbered as if each paragraph were a verse, progressively shifting topics.
- Drafted commentary corrections in Deuteronomy 23–27 against the bundled scripture; removed 16 non-existent verse keys from those chapters. November 7 review found that this includes new editorial prose, not just reference remapping. The user first retained it for review, then said “Looks good” after the document was shown and confirmed proceeding with the update. Editorial approval is recorded. `deuteronomy-commentary-review.md` preserves the exact previous/draft text for 99 changed references and all 16 removed entries.
- Combined complementary duplicate-key commentary fragments in John 8:19, 8:41, 8:58, Mark 11:33, and 12:37 into single entries for their original references.
- Removed byte-identical duplicate Proverbs chapter 2 and 16 blocks. Decoded scripture content is unchanged.
- Commentary panel now has a bounded, scrollable article, a persistent close control, and an explicit translation-load error state.
- Scripture width is capped on expanded windows; verse action sheets and chapter/verse grids adapt to narrow widths and larger text.
- Verse-image preview and font picker fit the current window; shared canvas font sizing remains proportional between preview and export.

## Checks performed

- `python3 scripts/validate_commentary.py`: passes focused Deuteronomy regressions, duplicate-key detection, and non-empty/content-copy checks across 66 scripture books and 66 commentary files.
- Verified those regression checks fail against the previous committed Deuteronomy mappings, including both reported harvest verses and the chapter 27 boundary-marker verse.
- `git diff --check`: passes.
- App Store update installed Xcode 27.2 (27B52), checked against Apple's public stable release listing.
- Debug app, extension, and test target compiled with Xcode 27.2. The existing 77-test suite passed, and the new bundled-content regression passed separately (78 tests total, no failures/skips) on iPhone 17 Pro / iOS 26.5.
- November 7: all 78 current tests passed together on iPhone 18 Pro / iOS 27.2 (24B114), zero failures/skips/runtime warnings. Evidence: `/tmp/aave-ios272-full-tests-20261107.xcresult`.
- November 7: all 78 current tests also passed on the official iPhone Duo / iOS 27.1 (24A94425), zero failures/skips/runtime warnings. Evidence: `/tmp/aave-duo271-full-tests-20261107.xcresult`. An initial simulator migration warning did not prevent successful test/app launch; Xcode also logged `invalidDigitCount(94425)` for the official runtime build identifier. Neither result proves folded/expanded visual correctness.
- Unsigned generic-iOS Release build succeeded with zero errors, 20 warnings, and zero analyzer warnings. Binary metadata confirms iOS 27.2 SDK, Xcode build 27B52, and minimum iOS 18.2.
- Final 1.7/build 24 verification succeeded after the version/SplashView changes: Release has zero errors, 18 warnings, zero analyzer warnings; Debug has zero errors, four warnings, zero analyzer warnings. The explicit Combine import removed two SplashView warnings. Both Release app and embedded extension report 1.7/build 24, SDK 27.2, Xcode 27B52, minimum iOS 18.2.
- Final versioned build passed all 78 tests on iPhone 17 Pro / iOS 26.5, zero failures/skips/runtime warnings. Evidence: `/tmp/aave-ios265-17-full-tests-20261107.xcresult` and `/tmp/aave-release-17-verification-20261107.xcresult`.
- Evidence: `/tmp/aave-full-tests-20261106-retry.xcresult`, `/tmp/aave-deuteronomy-regression-20261106.xcresult`, `/tmp/aave-release-verification-20261106.xcresult`.
- Stable iOS 27.2 simulator runtime installed. Its supported device list excludes Duo; the official iOS 27.1 runtime (24A94425) explicitly supports Duo and is now installed. Current-OS and Duo automated suites passed. Device visual checks, archive, upload, and App Store submission remain pending.
- November 7 App Store Connect readback: existing app ID `6742935082`, version 1.6; highest listed upload is build 23 (failed). Its exact errors are `90062` (short version must be higher than approved 1.6) and `90186` (1.6 pre-release train is closed). App and extension Debug/Release settings now use 1.7/build 24; SplashView has the matching release identifier and update notes. Final build/test verification after that version change passed. Created version **1.7 — Prepare for Submission** on this existing app and saved the four release-note bullets below. No upload or review submission yet.
- Sign-in restored and verified November 7. Business shows Free Apps Agreement **Active**, Paid Apps Agreement **Pending (New Agreement Available)**. Current app prices are zero in all 175 regions; In-App Purchases has no configured products. Apple's Paid Apps agreement glossary explicitly permits free app distribution without that optional agreement: https://developer.apple.com/help/glossary/paid-apps-agreement/. Do not treat the generic paid-agreement banner alone as proof that this free update is blocked. No legal, bank, tax, or price changes were made.
- Cloud `Default` workflow readback November 7: canonical repository/project/scheme; branch `backup-main`; Archive — iOS; Distribution Preparation **App Store Connect**; no post-actions. Both toolchain selectors use **Latest Release**, currently Xcode **27.2 (27B52)** and macOS Golden Gate **27.2 (26B123)**, not the local beta host. No workflow edit was necessary.
- Xcode's on-screen Run action now reports the app **Running on AAVE Release Verification iPhone Duo**. Native Device Hub control still times out; asked the owner to bring its window forward. This launch is not a completed pose/layout inspection.

## Existing content limitations

The structural audit reports 43 pre-existing out-of-range commentary references outside the corrected Deuteronomy chapters. `--strict` intentionally fails for those. Missing commentary is supported and is not filled with adjacent text. Structural checks and topic regression checks do not establish semantic accuracy of every commentary entry in the Bible.

The wider Deuteronomy scan also identified additional possible local topic slips (including 14:11, 28:3–4, 30:4–5, 31:9–11, 32:8–12, portions of 33, and 34:5/11). Those remain editorial review items; the release must not be described as a complete Bible-wide commentary review.

## Acceptance checklist

- [x] Review report and both screenshots, including ZIP inventory.
- [x] Obtain editorial approval for the retained explanations. Owner approved November 7; no resource wording changed after the passing tests.
- [x] Add reusable duplicate-aware content audit and targeted regressions.
- [x] Draft compact/expanded layout fixes.
- [x] Install and verify latest public stable Xcode.
- [x] Finish Xcode required-components installation.
- [x] Build production app in Debug and Release and run complete configured test suite.
- [x] Install stable iOS 27.2 simulator runtime.
- [ ] Verify iPhone Duo folded/unfolded, rotation, and large-text behavior.
- [ ] Verify verse-image preview/export geometry and commentary/action reachability.
- [x] Read current App Store Connect release/build metadata before assigning the next release version/build.
- [ ] Archive with stable Xcode and a supported stable build host; validate signing and upload processing.
- [ ] Attach build and submit the existing app's next version for review.

## Verification commands

```sh
python3 scripts/validate_commentary.py
git diff --check
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -checkFirstLaunchStatus
```

The final compatibility run used the existing iPhone 17 Pro / iOS 26.5 device:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test \
  -project 'AAVE Bible Concordance.xcodeproj' \
  -scheme 'AAVE Bible Concordance' \
  -destination 'platform=iOS Simulator,id=5C179744-DFD6-45CC-BEB1-2574E9D6205B' \
  -derivedDataPath /tmp/aave-device-assessment-derived \
  -clonedSourcePackagesDirPath /tmp/aave-device-assessment-packages \
  -jobs 2
```

The current-OS device is `66ED25BD-E054-4397-9896-36C84DE7F968` (iPhone 18 Pro / 27.2); the official Duo device is `4C4543F2-3544-413D-B050-BC64043F8BB5` (27.1). Use those identifiers in the same test command for the corresponding checks. Device/runtime availability is machine-specific.

Unsigned Release compilation (not a signed submission archive):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build \
  -project 'AAVE Bible Concordance.xcodeproj' \
  -scheme 'AAVE Bible Concordance' \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/aave-release-verification \
  -clonedSourcePackagesDirPath /tmp/aave-device-assessment-packages \
  -jobs 2 CODE_SIGNING_ALLOWED=NO
```

## Proposed What's New (publish only after validation)

- Fixed incorrect Real Talk Commentary appearing under certain Deuteronomy verses.
- Improved commentary and verse-action scrolling on smaller screens and with larger text.
- Improved reading layouts and chapter selection across compact and expanded displays.
- Improved verse-image sizing as the app window changes size.

## Current blockers

- Xcode's required system components finished successfully without a reboot. The first simulator boot failed after the update; direct boot recovery succeeded without deleting data or killing services, and the iOS 26.5 test run passed. Current-OS and Duo runs are separate remaining checks.
- The user accepted the updated Apple Developer Program License Agreement; account readback confirms acceptance November 6, 2026. No agreement was accepted by the agent. App Store Connect now opens from the authenticated developer account.
- Apple sign-in is now verified. Paid Applications terms remain pending, but Free Apps Agreement is active and this app is free with no configured in-app products. Continue free-update preparation without accepting paid terms or modifying bank/tax data; if submission specifically blocks on an agreement, hand that legal acceptance to the owner.
- Editorial gate cleared November 7 after the owner reviewed the document and said “Looks good.” Full source comparison remains in `Docs/AppStore/deuteronomy-commentary-review.md`.
- Stable Device Hub's native window controls repeatedly timed out (both direct launch and Xcode developer-tool entry); folded/expanded/large-text visual checks are not verified. Apple's supported pose controls are documented at https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub. No hidden simulator flags, profile spoofing, erasure, or service termination was used.
- Remaining pre-existing Release warnings include a SettingsView availability/result-builder warning, FoundationModels future enum handling, and deprecated APIs. No configured lint tool was found. Passing unit tests do not replace lower-OS Settings UI or notification cold/warm-launch checks.
- Editorial approval now permits release preparation. Stable-host archive/signing/upload processing and App Store review remain unverified. Local host build 26B5091g is a macOS beta build; prefer Xcode Cloud with explicitly stable Xcode/macOS versions rather than creating the submission archive on this host.
