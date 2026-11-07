# progress.md

## Current focus
- Steps: 4.2 and 7.1–7.2 from Docs/IMPLEMENTATION_PLAN.md
- Goal: Correct Deuteronomy commentary alignment, verify adaptive reader layouts, and prepare the next App Store update. See Docs/AppStore/next-release-readiness.md for evidence and remaining gates.

## Completed
- 2026-11-06: Reviewed Drive report/ZIP and both Deuteronomy screenshots; corrected commentary mappings in chapters 23–27 and duplicate JSON records.
- 2026-11-06: Added structural/content regressions and adaptive commentary, action-sheet, picker, reader-width, and verse-image layouts.
- 2026-11-06: Installed public stable Xcode 27.2 and stable iOS 27.2 runtime. Debug/Release builds succeeded; all 78 tests passed on iOS 26.5. iPhone Duo verification is pending.
- 2026-02-04: Added Home achievements summary card + perfect-score achievement.
- 2026-02-04: Updated leaderboard display names via users collection + cache.
- 2026-02-04: Added profile display name save to Firestore.

## In progress
- 2026-11-07: Official Duo-compatible iOS 27.1 runtime installed; all 78 tests passed on both iOS 27.2 and Duo/iOS 27.1. App Store upload 23 failed because approved version 1.6 is closed; prepared app+extension 1.7/build 24 and matching in-app notes. Final versioned Release build passed (zero errors, 18 existing warnings), and all 78 tests passed again on iOS 26.5.
- 2026-11-07: Review identified new editorial prose in the Deuteronomy draft. Saved exact before/after review in Docs/AppStore/deuteronomy-commentary-review.md; user subsequently reviewed it, said “Looks good,” and confirmed proceeding with the update. Editorial approval is recorded; resource wording is unchanged from passing tests.
- Dedicated iPhone Duo test/visual pass, followed by stable-host archive and App Store Connect release preparation.
- Duo automated tests passed; folded/expanded visual checks remain blocked by native Device Hub control timeouts. Apple sign-in is restored; Free Apps Agreement is active and this app's prices are zero. Optional Paid Apps terms remain pending; do not change legal/bank/tax settings unless a specific submission blocker requires owner action. Editorial gate is cleared. Cloud Default workflow resolves to stable Xcode 27.2/27B52 and macOS 27.2/26B123, unlike the local beta host.
- 2026-11-07: Created version 1.7 on existing App Store app 6742935082 and saved release notes; status Prepare for Submission, no build uploaded/submitted yet. Xcode launched the app on the dedicated Duo, but visual inspection still needs Device Hub control; owner asked to bring that window forward.
- 2026-11-07: Preserved remote pinned-verse fix eed0644 through a normal merge after non-fast-forward push rejection. Combined suite is now 80 tests, all passing on iOS 26.5; merged Release build passed with zero errors/18 existing warnings. Owner-approved App Review contact details are saved in App Store Connect, not in the repository.
- Add optional achievements empty-state CTA tuning (if needed).

## Next up
- Expand achievements summary styling and add analytics if desired.

## Known bugs / tech debt
- UsernamePromptView still exists but is no longer primary for display name.

## Notes for future sessions
- Consider migrating leaderboard to async/await Firestore once stable.
