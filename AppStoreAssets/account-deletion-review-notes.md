# Account Deletion Review Notes

App: **AAVE Bible Concordance**

## Where to find Delete Account
- Launch the app
- From the Home screen, tap the profile icon in the top-right corner
- In `Profile`, scroll to `Account Management`
- Tap `Delete Account`

## Exact navigation path
- `Home` → profile icon → `Profile` → `Account Management` → `Delete Account`

## What the flow does
- Shows a destructive confirmation alert with:
  - `This will permanently delete your account and associated app data. This action cannot be undone.`
  - The alert also lists the app data removed, including Firebase sign-in account, profile/display name, leaderboard identity, quiz scores, local bookmarks, highlights, notes, reading progress, streaks, and notification preferences.
- On final confirmation, the app:
  - Deletes the Firebase Auth account
  - Deletes the `users/{uid}` Firestore profile document if it exists
  - Deletes Firestore `quizScores` documents for that user
  - Attempts to remove known user-specific subcollections under `users/{uid}` if present
  - Clears local user data on device, including bookmarks, highlights, notes, reading history, reading progress, notification preferences, and onboarding/profile state
  - Shows `Account Deleted`
  - Returns the user to the onboarding / signed-out state after the reviewer taps `OK`

## Reauthentication behavior
- If Firebase requires a fresh credential, the app automatically launches the existing Sign in with Apple confirmation flow and then retries deletion.
- If the Apple confirmation is canceled or fails, the app shows a clear error and the user can restart the deletion flow.

## Limitations
- The current codebase supports Sign in with Apple reauthentication for deletion, but it does **not** separately call Apple’s credential revocation API. Deletion removes the Firebase account, local stored Apple user identifier, and app data.
- Based on the current repo schema, user-linked remote data is primarily stored in:
  - `users/{uid}`
  - `quizScores` documents where `userID == uid`

## Demo account instructions
- [INSERT DEMO ACCOUNT INSTRUCTIONS IF APP REVIEW NEEDS THEM]
