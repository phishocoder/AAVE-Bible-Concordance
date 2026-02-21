//
//  NotificationMessages.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/31/25.
//

import Foundation

struct NotificationMessages {
    enum MessageStyle {
        case standard
        case gentle
        case milestone
    }

    enum Category {
        case dailyVerse
        case midweekMotivation
        case weekendRefocus
        case betaFeedback
        case featureDiscovery(feature: String? = nil)
        case streakNudge
        case readInContext
        case celebrationBookFinished(book: String? = nil)
        case celebrationStreak7
        case celebrationQuizPersonalBest(score: Int)
    }

    private static let standardByCategory: [String: [String]] = [
        "dailyVerse": [
            "Your verse for today is ready when you are.",
            "A fresh verse is waiting for your day.",
            "Take a moment with today’s Word."
        ],
        "midweekMotivation": [
            "Midweek check-in: take a steady breath and read one verse.",
            "A midweek Word for strength and focus.",
            "Pause for a short reading today."
        ],
        "weekendRefocus": [
            "Weekend refocus: make a little room for Scripture.",
            "A weekend verse is ready for a quiet moment.",
            "Slow down for a short reading this weekend."
        ],
        "betaFeedback": [
            "Thanks for testing with us. Share feedback when you have a minute.",
            "Your feedback helps us improve the app with care.",
            "If anything feels off, send us a quick note."
        ],
        "featureDiscovery": [
            "You can compare translations side by side in Bible view.",
            "Try highlight colors to organize verses you want to revisit.",
            "A feature you might like is available: [FEATURE_PLACEHOLDER]."
        ],
        "streakNudge": [
            "A quiet reminder if you want to read today.",
            "You can take one short moment with Scripture tonight.",
            "If it helps, read one verse before the day closes."
        ],
        "readInContext": [
            "Open the chapter to read this verse in context.",
            "Context can add clarity. Read the full passage when ready.",
            "See the surrounding verses for the fuller picture."
        ]
    ]

    private static let gentleByCategory: [String: [String]] = [
        "dailyVerse": [
            "Today’s verse is here.",
            "A verse is ready when you want it.",
            "Here is a quiet verse for today."
        ],
        "midweekMotivation": [
            "A short midweek verse is ready.",
            "Midweek reading is available whenever you are.",
            "A brief Word for today."
        ],
        "weekendRefocus": [
            "Weekend verse is available.",
            "A weekend reading is here if you want it.",
            "A quiet weekend reminder."
        ],
        "betaFeedback": [
            "Thanks for using the app. Feedback is welcome.",
            "If you want, share a quick note about your experience.",
            "We’re listening whenever you want to send feedback."
        ],
        "featureDiscovery": [
            "Compare translations is available in Bible view.",
            "Highlight colors are available for saved verses.",
            "Feature available: [FEATURE_PLACEHOLDER]."
        ],
        "streakNudge": [
            "If you want, take a brief reading moment today.",
            "A gentle reminder for your reading time.",
            "A short reading is available whenever you are ready."
        ],
        "readInContext": [
            "Read the nearby verses for context when ready.",
            "Context view is available in Bible.",
            "Open the chapter if you want the full passage."
        ]
    ]

    private static let milestoneByCategory: [String: [String]] = [
        "dailyVerse": [
            "A new day to keep building in the Word.",
            "Another day, another moment with Scripture.",
            "Your reading rhythm is growing over time."
        ],
        "midweekMotivation": [
            "You are building steady midweek habits.",
            "Small moments in the Word are adding up.",
            "Your consistency this week matters."
        ],
        "weekendRefocus": [
            "You are keeping space for Scripture on weekends too.",
            "Your weekend rhythm is growing.",
            "Thank you for staying connected to the Word."
        ],
        "betaFeedback": [
            "Thank you for helping shape this app with your voice.",
            "Your thoughtful feedback is making this better.",
            "We appreciate your steady support and insight."
        ],
        "featureDiscovery": [
            "You are growing in how you use the app.",
            "Your study flow keeps getting stronger.",
            "Thanks for exploring the tools with intention."
        ],
        "streakNudge": [
            "Your steady reading matters.",
            "You have built meaningful momentum.",
            "Your daily faith practice is taking root."
        ],
        "readInContext": [
            "Your study depth is growing.",
            "Reading in context is strengthening your understanding.",
            "You are building a strong Scripture habit."
        ],
        "celebrationBookFinished": [
            "You finished [BOOK_PLACEHOLDER]. Well done.",
            "Book complete: [BOOK_PLACEHOLDER]. Strong work.",
            "You reached the end of [BOOK_PLACEHOLDER]. Keep going."
        ],
        "celebrationStreak7": [
            "Seven-day reading streak complete. Beautiful consistency.",
            "You reached a 7-day streak. Well done.",
            "A full week in the Word. Keep your steady rhythm."
        ],
        "celebrationQuizPersonalBest": [
            "New quiz personal best: [SCORE_PLACEHOLDER]. Nice work.",
            "You set a new quiz best at [SCORE_PLACEHOLDER].",
            "Personal best improved: [SCORE_PLACEHOLDER]. Keep sharpening."
        ]
    ]

    static let commentaryBooks = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
        "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
        "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
        "Ezra", "Nehemiah", "Esther", "Job", "Psalms",
        "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
        "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
        "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
        "Zephaniah", "Haggai", "Zechariah", "Malachi"
    ]

    private static var currentBookIndex: Int {
        get { UserDefaults.standard.integer(forKey: "currentCommentaryBookIndex") }
        set { UserDefaults.standard.set(newValue, forKey: "currentCommentaryBookIndex") }
    }

    private static var lastBookRotationDate: Date {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: "lastBookRotationDate")
            return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : Date.distantPast
        }
        set { UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastBookRotationDate") }
    }

    private static var displayName: String {
        UserDefaults.standard.string(forKey: "displayName")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    static func message(for category: Category, style: MessageStyle = .standard) -> String {
        let categoryKey = key(for: category)
        let source: [String]
        switch style {
        case .standard:
            source = standardByCategory[categoryKey] ?? []
        case .gentle:
            source = gentleByCategory[categoryKey] ?? standardByCategory[categoryKey] ?? []
        case .milestone:
            source = milestoneByCategory[categoryKey] ?? standardByCategory[categoryKey] ?? []
        }

        let base = randomMessage(from: source)
        let filled = replacePlaceholders(in: base, category: category)
        return personalize(filled, category: category, style: style)
    }

    static func getCommentaryNotification(style: MessageStyle = .standard) -> String {
        let book = getRotatingBook()
        let base = style == .gentle
            ? "New commentary is available for \(book)."
            : "Commentary update: \(book) is now available."
        return personalize(base, category: .featureDiscovery(feature: "Commentary"), style: style)
    }

    static func hasCommentary(for book: String) -> Bool {
        commentaryBooks.contains(book)
    }

    private static func key(for category: Category) -> String {
        switch category {
        case .dailyVerse: return "dailyVerse"
        case .midweekMotivation: return "midweekMotivation"
        case .weekendRefocus: return "weekendRefocus"
        case .betaFeedback: return "betaFeedback"
        case .featureDiscovery: return "featureDiscovery"
        case .streakNudge: return "streakNudge"
        case .readInContext: return "readInContext"
        case .celebrationBookFinished: return "celebrationBookFinished"
        case .celebrationStreak7: return "celebrationStreak7"
        case .celebrationQuizPersonalBest: return "celebrationQuizPersonalBest"
        }
    }

    private static func replacePlaceholders(in message: String, category: Category) -> String {
        var value = message
        if value.contains("[BOOK_PLACEHOLDER]") {
            let book: String
            if case let .celebrationBookFinished(maybeBook) = category {
                book = maybeBook ?? "this book"
            } else {
                book = getRotatingBook()
            }
            value = value.replacingOccurrences(of: "[BOOK_PLACEHOLDER]", with: book)
        }
        if value.contains("[FEATURE_PLACEHOLDER]"),
           case let .featureDiscovery(feature) = category {
            value = value.replacingOccurrences(of: "[FEATURE_PLACEHOLDER]", with: feature ?? "a helpful study tool")
        }
        if value.contains("[SCORE_PLACEHOLDER]"),
           case let .celebrationQuizPersonalBest(score) = category {
            value = value.replacingOccurrences(of: "[SCORE_PLACEHOLDER]", with: "\(score)")
        }
        return value
    }

    private static func personalize(_ message: String, category: Category, style: MessageStyle) -> String {
        guard style != .gentle else { return message }
        guard !displayName.isEmpty else { return message }
        switch category {
        case .dailyVerse, .streakNudge, .celebrationBookFinished, .celebrationStreak7, .celebrationQuizPersonalBest:
            return "\(message) \(displayName)."
        default:
            return message
        }
    }

    private static func randomMessage(from messages: [String]) -> String {
        messages.randomElement() ?? ""
    }

    static func getRotatingBook() -> String {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastBookRotationDate) {
            currentBookIndex = (currentBookIndex + 1) % commentaryBooks.count
            lastBookRotationDate = Date()
        }
        return commentaryBooks[currentBookIndex]
    }
}
