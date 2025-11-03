//
//  NotificationMessages.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/31/25.
//

import Foundation

struct NotificationMessages {
    static let dailyVerse = [
        "Let God say somethin' to you today. Your Verse of the Day just dropped.",
        "Go on and get that spiritual vitamin. Your daily Word is waitin'.",
        "Don't ghost the Bible today. It got somethin' for you."
    ]
    
    static let midweekMotivation = [
        "You made it to Wednesday. Let's keep that peace steady—see what God's sayin'.",
        "When the week feels long, open the Word—it hits different.",
        "You prayed for clarity, right? Go read today's verse."
    ]
    
    static let weekendRefocus = [
        "Weekend's here. Take a sec to refill your soul.",
        "Between brunch and naps, open the Word real quick.",
        "God ain't just for Sundays. Tap in today too."
    ]
    
    static let betaFeedback = [
        "You've been in the Word… now tell us how it feels.",
        "Lowkey: your feedback is how this app gets better. Drop us a note.",
        "Tried the highlight feature? Use it and let us know if it's hittin' or missin'."
    ]
    
    static let featureDiscovery = [
        "Psst… did you know you can compare translations? Go see what the NET and AAVE both say.",
        "Highlight hit different now. Pick your color and mark your faves.",
        "Just added [BOOK_PLACEHOLDER] commentary. It's deep. Go check it."
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
    
    static func randomMessage(from category: [String]) -> String {
        if let message = category.randomElement(), message.contains("[BOOK_PLACEHOLDER]") {
            return message.replacingOccurrences(of: "[BOOK_PLACEHOLDER]", with: getRotatingBook())
        }
        return category.randomElement() ?? category[0]
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
