# Account Deletion QA Checklist

## Core flow
- Create or sign in with a real account using Sign in with Apple.
- Open `Home` → profile icon → `Profile`.
- Confirm `Delete Account` is visible under `Account Management`.
- Tap `Delete Account` and verify the confirmation message appears.
- Tap `Cancel` and verify the account remains signed in.
- Re-open the flow and tap `Delete My Account`.
- Verify the warning lists Firebase sign-in account, profile/display name, leaderboard identity, quiz scores, bookmarks, highlights, notes, reading progress, streaks, and notification preferences.

## Successful deletion
- Verify the app does not crash during deletion.
- Verify the app shows `Account Deleted`.
- Tap `OK`.
- Verify the user is returned to the onboarding / signed-out state.
- Verify the profile no longer shows the deleted account as signed in.
- Verify the Firebase Auth user is deleted.
- Verify the Firestore `users/{uid}` document is deleted.
- Verify Firestore `quizScores` documents for that `uid` are deleted.
- Verify local bookmarks are cleared.
- Verify local highlights are cleared.
- Verify local notes are cleared.
- Verify local reading history / progress are cleared.
- Verify local notification preferences are reset.

## Reauthentication path
- Sign in, wait long enough for Firebase to require recent login, then trigger deletion.
- Verify the app automatically launches the existing Sign in with Apple confirmation flow.
- Verify deletion succeeds after reauthentication.

## Failure handling
- Test with network unavailable and verify a clear network error appears.
- Test with Firestore permission failure if possible and verify a clear error appears.
- Test the missing-user path if possible and verify the app handles it gracefully.
- Verify the app never deletes shared/global Bible content or public app configuration.

## Post-delete validation
- Verify the deleted user cannot sign back in with the same credentials unless the account is recreated by the auth provider flow.
- Verify leaderboard identity for the deleted user is no longer shown from deleted `quizScores` data.
- Verify App Review can follow the screen recording path clearly from app launch to deletion confirmation.

## Suggested App Review screen recording path
- Launch app
- Tap profile icon
- Show `Delete Account`
- Tap `Delete Account`
- Show destructive confirmation
- Confirm deletion
- Show `Account Deleted`
- Tap `OK`
- Show return to onboarding / signed-out state
