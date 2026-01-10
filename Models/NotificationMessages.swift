//
//  NotificationMessages.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/31/25.
//

import Foundation

struct NotificationMessages {
    static let dailyVerse = [
        "Here’s a little light for your day—no pressure, just a vibe.",
        "Take a moment, catch a verse, and breathe in some peace.",
        "Your daily Word’s here, just a gentle invite to connect.",
        "No rush, no fuss—just a verse to hold with you today.",
        "A little spiritual boost, whenever you’re ready.",
        "Open up and see what wisdom’s waiting for you now.",
        "A calm reminder: there’s always space for a good word.",
        "Catch a verse, catch a breath, catch your peace.",
        "Today’s Word is here—feel free to lean into it.",
        "A soft nudge toward your soul’s refreshment."
    ]
    
    static let dailyVerse_chill = [
        "Just a chill verse to vibe with when you got a sec.",
        "Take a beat, catch a verse, no stress attached.",
        "Your daily Word, served easy and laid-back.",
        "No pressure—just a little something for your spirit.",
        "Slide into today’s Word whenever you feel like it."
    ]
    
    static let dailyVerse_deep = [
        "Dive a little deeper today with a verse to ponder.",
        "A verse to hold close and let sink in slowly.",
        "Let today’s Word speak softly but powerfully to you.",
        "A moment to reflect on the wisdom that moves you.",
        "Seek the depth in today’s gentle invitation."
    ]
    
    static let midweekMotivation = [
        "Halfway through—take a moment to center yourself.",
        "Midweek peace is real. Let a verse guide you.",
        "Recharge your spirit with a quick Word break.",
        "Wednesday’s here—steady your heart with some truth.",
        "Pause, breathe, and lean into today’s message.",
        "Keep your vibe steady with a little midweek Word.",
        "A gentle lift to help you glide through the day.",
        "Find your calm in the middle of the hustle."
    ]
    
    static let weekendRefocus = [
        "Weekend’s here—slow down and refresh your soul.",
        "Take a beat between plans to soak in some peace.",
        "Rest your mind, feed your spirit with a quick verse.",
        "Let the weekend vibes include a little Word time.",
        "Recharge and realign with a verse that speaks to you.",
        "Find quiet moments to reconnect with your soul.",
        "Between chill and grind, make space for your spirit.",
        "A soft reminder: your soul deserves some weekend love."
    ]
    
    static let betaFeedback = [
        "Thanks for being part of this journey—your thoughts matter.",
        "We appreciate you! Got a sec to share your vibe with us?",
        "Your feedback helps us grow—drop a note when you can.",
        "Love the app? Something to tweak? Let us know kindly.",
        "Your voice shapes this space—thank you for sharing.",
        "Help us make this better, one message at a time."
    ]
    
    static let featureDiscovery = [
        "Psst… did you know you can compare translations? Go see what the NET and AAVE both say.",
        "Highlight hit different now. Pick your color and mark your faves.",
        "Just added [BOOK_PLACEHOLDER] commentary. It's deep. Go check it.",
        "Try out [FEATURE_PLACEHOLDER]—it’s designed to make your experience smoother.",
        "Discover how [FEATURE_PLACEHOLDER] can bring fresh vibes to your reading.",
        "New feature alert: [FEATURE_PLACEHOLDER]! Give it a spin and see what you think.",
        "Explore [FEATURE_PLACEHOLDER] and find new ways to connect with the Word.",
        "Unlock fresh insights with [FEATURE_PLACEHOLDER]—your spiritual toolkit just got better.",
        "Dive into [FEATURE_PLACEHOLDER] and see how it fits your flow.",
        "Heads up! [FEATURE_PLACEHOLDER] is live. Tap in and explore."
    ]
    
    static let streakNudge = [
        "Your streak’s looking good—keep it flowing, no pressure.",
        "One minute is all it takes to keep your streak alive.",
        "Quick tap, big impact—your streak’s waiting for you.",
        "Keep the vibe going, your streak’s worth a moment.",
        "Every day counts—no guilt, just steady love for your soul.",
        "Streaks are about connection, not perfection. You got this.",
        "Feel that streak energy? It’s just a gentle reminder.",
        "Stay in your groove—your streak’s here to support you.",
        "It’s cool to pause, but your streak’s here when you’re ready.",
        "Celebrate your progress—streaks are about showing up for you."
    ]
    
    static let streakNudge_chill = [
        "No stress, just a chill nudge to keep your streak alive.",
        "A quick tap keeps your streak going—easy does it.",
        "Your streak’s cool and steady, just like you.",
        "Keep it light, keep it easy—your streak’s waiting.",
        "Stay breezy and keep your streak in the mix."
    ]
    
    static let streakNudge_deep = [
        "Your streak is a journey, not a race—keep flowing.",
        "Each day you show up, your streak grows in meaning.",
        "Honor your streak as a step in your spiritual path.",
        "Deep roots grow from steady streaks—keep nurturing.",
        "Your streak reflects commitment, not perfection."
    ]
    
    static let readInContext = [
        "Tap 'Read in context' to see the full story around your verse.",
        "Get the bigger picture—open the chapter and dive deeper.",
        "Explore the verse’s neighborhood with ‘Read in context.’",
        "See how today’s verse fits in the whole chapter’s vibe.",
        "Reading in context brings the Word to life—give it a try.",
        "Open the chapter for a fuller, richer connection.",
        "Discover the story behind the verse with a quick tap.",
        "Let the context deepen your understanding and peace."
    ]
    
    // Books with available commentary
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
    
    // Index for rotating through books (persisted between app launches)
    private static var currentBookIndex: Int {
        get { UserDefaults.standard.integer(forKey: "currentCommentaryBookIndex") }
        set { UserDefaults.standard.set(newValue, forKey: "currentCommentaryBookIndex") }
    }
    
    // Date of last book rotation
    private static var lastBookRotationDate: Date {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: "lastBookRotationDate")
            return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : Date.distantPast
        }
        set { UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastBookRotationDate") }
    }
    
    private static var tonePreference: String {
        UserDefaults.standard.string(forKey: "tonePreference") ?? "mix"
    }

    private static var faithVibe: String {
        UserDefaults.standard.string(forKey: "faithVibe") ?? ""
    }

    private static var displayName: String {
        UserDefaults.standard.string(forKey: "displayName")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    enum Category {
        case dailyVerse
        case midweekMotivation
        case weekendRefocus
        case betaFeedback
        case featureDiscovery(feature: String? = nil)
        case streakNudge
        case readInContext
    }
    
    static func message(for category: Category) -> String {
        let baseMessage: String
        switch category {
        case .dailyVerse:
            if tonePreference.range(of: "chill", options: .caseInsensitive) != nil {
                baseMessage = randomMessage(from: dailyVerse_chill)
            } else if tonePreference.range(of: "deep", options: .caseInsensitive) != nil {
                baseMessage = randomMessage(from: dailyVerse_deep)
            } else {
                baseMessage = randomMessage(from: dailyVerse)
            }
        case .midweekMotivation:
            baseMessage = randomMessage(from: midweekMotivation)
        case .weekendRefocus:
            baseMessage = randomMessage(from: weekendRefocus)
        case .betaFeedback:
            baseMessage = randomMessage(from: betaFeedback)
        case .featureDiscovery(let feature):
            baseMessage = randomMessage(from: featureDiscovery, feature: feature)
        case .streakNudge:
            if tonePreference.range(of: "chill", options: .caseInsensitive) != nil {
                baseMessage = randomMessage(from: streakNudge_chill)
            } else if tonePreference.range(of: "deep", options: .caseInsensitive) != nil {
                baseMessage = randomMessage(from: streakNudge_deep)
            } else {
                baseMessage = randomMessage(from: streakNudge)
            }
        case .readInContext:
            baseMessage = randomMessage(from: readInContext)
        }
        return personalize(baseMessage, for: category)
    }

    private static func personalize(_ message: String, for category: Category) -> String {
        switch category {
        case .dailyVerse, .streakNudge:
            break
        default:
            return message
        }
        guard !displayName.isEmpty else { return message }

        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = trimmed.last else { return message }

        let punctuation: Set<Character> = [".", "!", "?"]
        if punctuation.contains(last) {
            let base = trimmed.dropLast()
            return "\(base), \(displayName)."
        }

        return "\(trimmed), \(displayName)"
    }
    
    static func randomMessage(from category: [String], feature: String? = nil) -> String {
        if let message = category.randomElement() {
            var result = message
            if result.contains("[BOOK_PLACEHOLDER]") {
                result = result.replacingOccurrences(of: "[BOOK_PLACEHOLDER]", with: getRotatingBook())
            }
            if result.contains("[FEATURE_PLACEHOLDER]") {
                result = result.replacingOccurrences(of: "[FEATURE_PLACEHOLDER]", with: feature ?? "new feature")
            }
            return result
        }
        return category[0]
    }
    
    static func getRotatingBook() -> String {
        // Check if we need to rotate to a new book (daily rotation)
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastBookRotationDate) {
            // Advance to next book
            currentBookIndex = (currentBookIndex + 1) % commentaryBooks.count
            lastBookRotationDate = Date()
        }
        
        return commentaryBooks[currentBookIndex]
    }
    
    // Get a commentary notification with the current rotating book
    static func getCommentaryNotification() -> String {
        let book = getRotatingBook()
        return "Just added \(book) commentary. It's deep. Go check it."
    }
    
    // Check if a book has commentary available
    static func hasCommentary(for book: String) -> Bool {
        return commentaryBooks.contains(book)
    }
}
