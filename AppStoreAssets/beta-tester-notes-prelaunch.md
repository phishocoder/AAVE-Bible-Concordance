# Beta Tester Notes - Pre-Launch Build

This is a pre-launch build focused on App Store readiness, account controls, and final polish before public release.

## What is new

- Account deletion is now available in the app.
- Go to `Home -> profile icon -> Profile -> Account Management -> Delete Account`.
- The deletion flow now explains exactly what will be removed before you confirm.
- After deletion completes, the app shows an `Account Deleted` confirmation before returning you to onboarding/sign-in.
- Weekly leaderboard support is in place so public rankings refresh by week instead of letting old perfect scores sit forever.
- Quiz leaderboard submissions now require a real display name instead of placeholder `Reader ####` names.
- App Store screenshot and submission assets have been prepared for iPhone and iPad.
- FullStory demo/example code has been removed from the shipping app.
- Firestore rules were updated to support user-owned account deletion data cleanup.

## What to test

- Sign in with Apple, then confirm your profile shows as signed in.
- Start the account deletion flow and verify the warning clearly lists what will be deleted.
- Tap `Cancel` first and confirm your account remains signed in.
- Run deletion again, confirm it, and complete Apple confirmation if it appears.
- Verify the app shows `Account Deleted` before sending you back to onboarding/sign-in.
- Finish a quiz and confirm the leaderboard asks for a real name if your display name is blank or a placeholder.
- Check that the leaderboard says `Top Scores (This Week)`.
- Open Bible reading, commentary, bookmarks, notifications, and the main tabs for any crashes or broken navigation.

## Expected behavior

- Apple may ask you to confirm your identity before account deletion completes. That is expected.
- After account deletion, the deleted account should no longer appear as signed in.
- User-specific data such as profile/display name, leaderboard identity, quiz scores, bookmarks, highlights, notes, reading progress, streaks, and notification preferences should be removed or reset.
- Public Bible content, commentary, and quiz questions should remain available.

## Please report

- Any crash, freeze, or screen that gets stuck.
- Any account deletion step that is confusing or does not match the notes above.
- Any leaderboard name that still appears as a placeholder.
- Any missing or broken tab, Bible reading screen, commentary view, bookmark flow, or notification setting.
- Screenshots or screen recordings are most useful when something looks wrong.

## Build note

This build is intended for pre-launch validation before App Review resubmission. The highest-priority test is the account deletion flow.
