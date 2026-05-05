# AAVE Bible Concordance Privacy Policy

Last updated: May 1, 2026

This privacy policy applies to **AAVE Bible Concordance** and the related website **https://officialaavebible.com**.

## Overview
AAVE Bible Concordance is a Bible reading and study app. The app includes Scripture reading, commentary, bookmarks, notes, quizzes, leaderboard features, notifications, and account features.

We aim to collect as little personal information as possible and to keep core reading features available without requiring heavy account setup.

## Information We May Collect

### 1. Account and profile information
If you use account-related features, we may process:
- Display name or first name
- Anonymous account identifier generated through Firebase Authentication
- Sign in with Apple account data needed for authentication

Based on the current app code, the app stores a display name for profile and leaderboard use. The app also supports anonymous sign-in and Sign in with Apple via Firebase Authentication.

### 2. Leaderboard and quiz activity
If you use quiz and leaderboard features, we may store:
- User identifier
- Quiz score
- Quiz type
- Timestamp
- Weekly leaderboard grouping fields
- Leaderboard display name

This data is used to show quiz results, personal bests, and community leaderboard entries.

### 3. Notifications
If you allow notifications, the app may process:
- Notification permission status
- Device push token / Firebase Cloud Messaging token
- Notification preferences
- Notification engagement related to Bible reading reminders and app prompts

### 4. Analytics and session diagnostics
The app codebase includes:
- Firebase Analytics

These tools may collect app usage, device/app interaction data, and diagnostic telemetry to understand feature usage and improve the product. Release configuration should be reviewed before publication so disclosures match the exact shipped behavior.

### 5. Local on-device data
The app stores some information locally on your device, including:
- Bookmarks
- Verse notes
- Reading history
- Reading progress
- Onboarding choices
- Tone and notification preferences
- Display name

This local data is used to personalize the in-app experience and support offline or low-friction use.

## Information We Do Not Intend To Sell
We do **not** sell your personal information.

## How We Use Information
We use information to:
- Authenticate users
- Show your display name in account and leaderboard features
- Save quiz progress and leaderboard results
- Deliver reminders and push notifications
- Improve app stability, usability, and feature quality
- Personalize your study experience

## Third-Party Services
Based on the current app repository, the app uses or references:
- **Firebase Authentication**
- **Firebase Firestore**
- **Firebase Messaging**
- **Firebase Analytics**
The app also fetches some traditional Bible translation content from:
- **https://labs.bible.org/api**

Please review the privacy terms of those providers before release to ensure your published App Store disclosures and public privacy page stay aligned.

## Children’s Privacy
The app is designed as a general audience Bible study product. It is not specifically directed to children under 13.

## Data Retention
Some data is stored locally on your device until you remove it or delete the app. Cloud-backed quiz/account data may remain in backend systems until removed according to operational needs.

## Your Choices
You may be able to:
- Disable notifications in iOS Settings
- Avoid optional sign-in features
- Clear local app data by removing the app or using in-app controls where available
- Update your display name from the app profile flow

## Public or shared content
If you choose a display name for leaderboard use, that name may be visible to other users inside the leaderboard experience.

## Contact
For privacy questions, contact:

**[INSERT CONTACT EMAIL]**

## Website
Website: **https://officialaavebible.com**

## Important release note
This markdown file was prepared from the current iOS repository to help publish an accurate public-facing privacy policy. Before posting it at `/privacy` or `/privacy-policy` on your website, confirm the final release build behavior, especially around analytics and authentication.
