import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    // Current navigation state
    @Published var currentBook: String = ""
    @Published var currentChapter: Int = 0
    @Published var currentVerse: Int = 0
    
    // Add debouncing to prevent rapid navigation requests
    private var lastNavigationTime: Date = Date.distantPast
    private let navigationThrottleInterval: TimeInterval = 0.3
    
    // Navigation request structure
    struct NavigationRequest: Equatable {
        let book: String
        let chapter: Int
        let verse: Int?
        let highlightVerse: Bool
        
        init(book: String, chapter: Int, verse: Int? = nil, highlightVerse: Bool = false) {
            self.book = book
            self.chapter = chapter
            self.verse = verse
            self.highlightVerse = highlightVerse
        }
    }
    
    // Published navigation request property
    @Published var navigationRequest: NavigationRequest?
    
    private init() {
        // Load last viewed chapter from UserDefaults if available
        if let lastBook = UserDefaults.standard.string(forKey: "lastViewedBook"),
           let lastChapter = UserDefaults.standard.integer(forKey: "lastViewedChapter") as Int? {
            currentBook = lastBook
            currentChapter = lastChapter
            currentVerse = UserDefaults.standard.integer(forKey: "lastViewedVerse")
        }
    }
    
    // Navigate to a specific chapter
    func navigateToChapter(book: String, chapter: Int) {
        navigateToVerse(book: book, chapter: chapter, verse: nil, highlightVerse: false)
    }
    
    func clearNavigationRequest() {
        navigationRequest = nil
    }
    
    func navigateToVerse(book: String, chapter: Int, verse: Int?, highlightVerse: Bool) {
        // Prevent multiple rapid navigation requests
        let now = Date()
        guard now.timeIntervalSince(lastNavigationTime) > navigationThrottleInterval else {
            print("NavigationManager: Throttling navigation request")
            return
        }
        lastNavigationTime = now
        
        // Create a navigation request
        let request = NavigationRequest(
            book: book,
            chapter: chapter,
            verse: verse,
            highlightVerse: highlightVerse
        )
        
        print("NavigationManager: Creating navigation request to \(book) \(chapter):\(verse ?? 0)")
        
        // Update current state
        currentBook = book
        currentChapter = chapter
        if let verse = verse {
            currentVerse = verse
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(book, forKey: "lastViewedBook")
        UserDefaults.standard.set(chapter, forKey: "lastViewedChapter")
        if let verse = verse {
            UserDefaults.standard.set(verse, forKey: "lastViewedVerse")
        }
        
        // Set the request to trigger navigation
        // This is important - set it last to ensure all state is updated first
        DispatchQueue.main.async {
            self.navigationRequest = request
            
            // Also post a direct notification for components that might not be observing the published property
            NotificationCenter.default.post(
                name: Notification.Name("DirectNavigationRequest"),
                object: nil,
                userInfo: [
                    "book": book,
                    "chapter": chapter,
                    "verse": verse as Any,
                    "highlightVerse": highlightVerse
                ]
            )
        }
    }
}
