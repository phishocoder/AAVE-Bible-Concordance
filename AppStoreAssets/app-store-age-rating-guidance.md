# App Store Age Rating Guidance

Prepared for: **AAVE Bible Concordance**

## Recommended overall direction
This app is a **religious / Bible study / reference** product with reading, commentary, bookmarks, quizzes, notifications, and limited community leaderboard functionality.

It does **not** appear to include:
- Sexual content
- Gambling
- Alcohol, tobacco, or drug use themes as app features
- Medical or treatment advice
- Open chat, posting, or community feed features
- In-app unrestricted browsing

## Recommended answers by topic

### Unrestricted Web Access
Recommended answer: **No**

Why:
- The app opens fixed external links such as the website, privacy policy link, and social links.
- The repo does **not** show a general in-app browser or arbitrary web browsing surface.

Human confirmation needed:
- Confirm no hidden web view or admin/debug browser exists in release.

### User-Generated Content
Recommended answer: **No** for broad public posting/community creation

Why:
- There is no feed, comments, chat, or posting system in the repo.
- The only public-facing user input I found is leaderboard display name text tied to quiz scores.

Human confirmation needed:
- App Store may treat leaderboard display names as limited user-submitted content. If Apple’s wording is strict, answer conservatively and note it is limited to player name display only.

### Violence
Recommended answer: **Infrequent / Mild** at most, pending your comfort level

Why:
- The app contains biblical and commentary text, and Scripture includes references to war, death, demons, crucifixion, and judgment.
- I did **not** find graphic visual depictions or gameplay violence.

Human confirmation needed:
- Decide whether to mark this `None` or `Infrequent/Mild` based on how conservative you want to be with biblical text themes.
- My safer recommendation is **Infrequent / Mild** because the content is text-based but can reference violence.

### Horror / Fear Themes
Recommended answer: **None** or **Infrequent / Mild**

Why:
- Some biblical passages and commentary can reference demons, judgment, spiritual warfare, and fear-related themes.
- No horror mechanics or graphic imagery were found.

Human confirmation needed:
- If you want the strictest truthful answer, consider **Infrequent / Mild**.

### Sexual Content or Nudity
Recommended answer: **No**

Why:
- No sexual feature set or explicit sexual presentation was found in the app UI/flows.

### Profanity or Crude Humor
Recommended answer: **No** or **Infrequent / Mild** only if you want to be extra conservative

Why:
- The app uses conversational AAVE-style phrasing, but I did not audit it as a profanity-heavy app.
- Religious text context may include strong biblical themes without modern profanity focus.

Human confirmation needed:
- If you know certain commentary lines contain stronger language than usual App Store expectations, raise this to `Infrequent / Mild`.

### Gambling / Contests
Recommended answer: **No**

Why:
- Quiz and leaderboard features are present, but there is no gambling, wagering, or cash value mechanic.

### Medical / Treatment Information
Recommended answer: **No**

Why:
- This is a Bible study app, not a health or treatment product.

## Likely age band
Most likely result: **4+**, **9+**, or **12+** depending on how Apple interprets scriptural violence/fear themes.

My conservative recommendation:
- Expect a rating around **9+** or **12+** if you answer violence/fear themes as `Infrequent / Mild`

## Manual review checklist
Before answering in App Store Connect, confirm:
1. Whether leaderboard names should count as user-generated content for Apple’s form wording.
2. Whether you want to disclose biblical violence/fear themes as `None` or `Infrequent / Mild`.
3. That release builds do not expose any unrestricted in-app browsing surface.
