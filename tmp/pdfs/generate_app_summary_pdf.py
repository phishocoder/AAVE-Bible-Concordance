from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics

OUTPUT = "output/pdf/aave_bible_app_summary.pdf"

c = canvas.Canvas(OUTPUT, pagesize=letter)
width, height = letter

left = 0.7 * inch
right = width - 0.7 * inch
y = height - 0.65 * inch


def draw_text(text, x, y_pos, font="Helvetica", size=10):
    c.setFont(font, size)
    c.drawString(x, y_pos, text)


def draw_wrapped(text, x, y_pos, max_width, font="Helvetica", size=10, leading=13):
    words = text.split()
    line = ""
    lines = []
    for word in words:
        candidate = f"{line} {word}".strip()
        if pdfmetrics.stringWidth(candidate, font, size) <= max_width:
            line = candidate
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)

    c.setFont(font, size)
    for l in lines:
        c.drawString(x, y_pos, l)
        y_pos -= leading
    return y_pos


def section(title, y_pos):
    draw_text(title, left, y_pos, font="Helvetica-Bold", size=11)
    return y_pos - 14


draw_text("AAVE Bible Concordance - App Summary", left, y, font="Helvetica-Bold", size=16)
y -= 20
draw_text("Evidence source: README.md, Docs/*.md, and implementation files in this repo.", left, y, font="Helvetica-Oblique", size=8.5)
y -= 18

# What it is
y = section("What it is", y)
y = draw_wrapped(
    "A SwiftUI iOS Bible-reading app focused on Scripture access in AAVE with optional traditional translation comparison and commentary support. "
    "The product is positioned as a reading and discipleship tool with local-first content for reliable access.",
    left,
    y,
    right - left,
    size=10,
)
y -= 6

# Who it's for
y = section("Who it's for", y)
y = draw_wrapped(
    "Primary persona: everyday believers who want clear Scripture reading plus commentary in culturally fluent language (Docs/PRD.md).",
    left,
    y,
    right - left,
    size=10,
)
y -= 6

# What it does
y = section("What it does", y)
features = [
    "Five-tab navigation: Home, Bible, Search, Bookmarks, and More (Views/MainView.swift).",
    "Loads bundled AAVE Bible and commentary JSON from app resources for baseline offline reading (Views/Services/TranslationService.swift).",
    "Supports verse/chapter reading with commentary drill-in and deep-link navigation to verse detail (Views/MainView.swift).",
    "Provides search and direct navigation to book/chapter/verse results with empty/loading states (Views/SearchView.swift).",
    "Lets users save/manage bookmarks, highlights, and notes with local persistence (Views/BookmarkView.swift, Views/Services/UserDataManager.swift).",
    "Schedules verse-of-day and related notifications, with optional lock-screen live activity updates (Views/Services/NotificationManager.swift).",
    "Includes quiz scoring and leaderboard-related Firebase/Firestore integrations (Views/Services/FirestoreService.swift, Docs/TECH_STACK.md).",
]
for item in features:
    y = draw_wrapped(f"- {item}", left, y, right - left, size=9.6, leading=12)
    y -= 1

y -= 4

# How it works
y = section("How it works (architecture from repo evidence)", y)
arch_items = [
    "UI layer: SwiftUI app entry injects shared state/services (settings, network monitor, notification manager, router, auth manager).",
    "Core content: TranslationService discovers bundled AAVE/commentary JSON, loads content in memory, and builds a local search index.",
    "Verse retrieval flow: VerseManager routes AAVE requests to TranslationService; non-AAVE requests go to BibleAPIService (labs.bible.org), with local file/cache support for downloaded books.",
    "State + personalization: UserDefaults-backed services persist reading history, notes, bookmarks/highlights, progress streaks, and simple rule-based personalization.",
    "Remote integrations: AppDelegate configures Firebase (Auth, Messaging); FirestoreService persists quiz scores. Detailed crash-reporting setup: Not found in repo.",
]
for item in arch_items:
    y = draw_wrapped(f"- {item}", left, y, right - left, size=9.3, leading=11.5)
    y -= 1

y -= 4

# How to run
y = section("How to run (minimal)", y)
run_steps = [
    "Open `AAVE Bible Concordance.xcodeproj` in Xcode.",
    "Ensure local Firebase config exists if you need auth/leaderboard/push features (`AAVE Bible Concordance/GoogleService-Info (1).plist`).",
    "Build and run on simulator/device, or run: `xcodebuild -project \"AAVE Bible Concordance.xcodeproj\" -scheme \"AAVE Bible Concordance\" -destination 'generic/platform=iOS' build`.",
    "Exact CI pipeline and release process: Not found in repo.",
]
for step in run_steps:
    y = draw_wrapped(f"- {step}", left, y, right - left, size=9.3, leading=11.5)
    y -= 1

# Safety check label at bottom
c.setFont("Helvetica-Oblique", 8)
c.drawRightString(right, 0.4 * inch, "Generated from repository evidence only")

c.showPage()
c.save()
print(OUTPUT)
