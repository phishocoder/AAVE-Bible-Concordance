//
//  AppState.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    // App loading state
    @Published var isLoading: Bool = true
    @Published var loadingProgress: Double = 0.0
    @Published var isInitialLoadComplete: Bool = false
    
    // Navigation state
    @Published var currentBook: String = "Genesis"
    @Published var currentChapter: Int = 1
    @Published var currentVerse: Int = 1
    @Published var highlightedVerse: Int? = nil
    @Published var isNavigating: Bool = false
    
    // Selection state
    @Published var selectedVerses: Set<Int> = []
    @Published var isMultiSelectMode: Bool = false
    @Published var selectedVerse: Verse? = nil
    
    // Overlay state
    @Published var showVerseActions: Bool = false
    @Published var showCommentary: Bool = false
    @Published var commentaryVerse: Verse? = nil
    @Published var commentaryReference: VerseReference? = nil
    
    // Search state
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    @Published var searchResults: [VerseReference] = []
    
    // Network state
    @Published var isOnline: Bool = true
    
    // Refresh triggers
    @Published var refreshID = UUID()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set initial loading state
        self.isLoading = true
        
        // Subscribe to network status changes
        NetworkMonitor.shared.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                self?.isOnline = isConnected
            }
            .store(in: &cancellables)
        
        // Subscribe to navigation changes
        NotificationCenter.default.publisher(for: Notification.Name("NavigationChanged"))
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                if let book = notification.userInfo?["book"] as? String,
                   let chapter = notification.userInfo?["chapter"] as? Int {
                    self?.currentBook = book
                    self?.currentChapter = chapter
                    if let verse = notification.userInfo?["verse"] as? Int {
                        self?.currentVerse = verse
                        self?.highlightedVerse = verse
                    }
                }
            }
            .store(in: &cancellables)
        
        // Simulate loading time and progress
        simulateLoading()
    }
    
    private func simulateLoading() {
        // Simulate loading progress
        var progress = 0.0
        let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        
        timer.sink { [weak self] _ in
            guard let self = self else { return }
            
            progress += 0.05
            self.loadingProgress = min(progress, 1.0)
            
            if progress >= 1.0 {
                self.isInitialLoadComplete = true
                timer.upstream.connect().cancel()
            }
        }
        .store(in: &cancellables)
    }
    
    func continueToApp() {
        self.isLoading = false
    }
    
    func navigateTo(book: String, chapter: Int, verse: Int? = nil) {
        // Post notification for navigation
        var userInfo: [String: Any] = ["book": book, "chapter": chapter]
        if let verse = verse {
            userInfo["verse"] = verse
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToVerse"),
            object: nil,
            userInfo: userInfo
        )
        
        // Update local state
        self.currentBook = book
        self.currentChapter = chapter
        if let verse = verse {
            self.currentVerse = verse
            self.highlightedVerse = verse
        }
    }
    
    func refreshContent() {
        self.refreshID = UUID()
    }
    
    func enterMultiSelectMode() {
        self.isMultiSelectMode = true
        self.selectedVerses = []
    }
    
    func exitMultiSelectMode() {
        self.isMultiSelectMode = false
        self.selectedVerses = []
    }
    
    func toggleVerseSelection(_ verseNumber: Int) {
        if selectedVerses.contains(verseNumber) {
            selectedVerses.remove(verseNumber)
        } else {
            selectedVerses.insert(verseNumber)
        }
    }
    
    func showCommentaryFor(reference: VerseReference) {
        self.commentaryReference = reference
        self.showCommentary = true
    }
}
