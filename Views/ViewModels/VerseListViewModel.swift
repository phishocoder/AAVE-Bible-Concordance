//
//  VerseListViewModel.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI
import Combine

@MainActor
class VerseListViewModel: ObservableObject {
    // Bible data
    @Published var currentBook: String { didSet { persistLocation() } }
    @Published var currentChapter: Int { didSet { persistLocation() } }
    @Published var verses: [Verse] = []
    @Published var isLoading = false
    @Published var refreshID = UUID()
    
    // Selection state
    @Published var isMultiSelectMode = false
    @Published var selectedVerses: [Verse] = []
    @Published var selectedVerse: Verse? = nil
    @Published var highlightedVerse: Int? = nil
    @Published var isNavigating: Bool = false
    
    // Overlay state
    @Published var showVerseActions = false
    @Published var showCommentary = false
    @Published var commentaryVerse: Verse? = nil
    @Published var commentaryReference: VerseReference? = nil
    @Published var showingImageOptions = false
    @Published var lastVisibleVerse: Int? { didSet { persistLocation() } }
    
    private var translationService = TranslationService.shared
    private var verseManager = VerseManager.shared
    private var userDataManager = UserDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    private let lastBookKey = "lastBook"
    private let lastChapterKey = "lastChapter"
    private let lastVerseKey = "lastVerse"
    
    init(book: String, chapter: Int, initialVerse: Int? = nil) {
        // Restore last location unless a specific navigation target was provided.
        let storedBook = defaults.string(forKey: lastBookKey)
        let storedChapter = defaults.integer(forKey: lastChapterKey)
        let storedVerse = defaults.integer(forKey: lastVerseKey)
        
        let shouldUseProvided = initialVerse != nil
            || storedBook == nil
            || storedBook != book
            || (storedChapter > 0 && storedChapter != chapter)
        
        let startBook = shouldUseProvided ? book : (storedBook ?? book)
        let startChapter = shouldUseProvided ? chapter : (storedChapter > 0 ? storedChapter : chapter)
        let startVerse = initialVerse ?? (storedVerse > 0 ? storedVerse : nil)
        
        self.currentBook = startBook
        self.currentChapter = startChapter
        self.highlightedVerse = startVerse
        self.lastVisibleVerse = startVerse
        
        persistLocation()
    }
    
    func forceReload() {
        Task {
            await loadVerses()
            // Use a small delay to ensure UI updates properly
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                self.refreshID = UUID()
            }
        }
    }
    
    func loadVerses() async {
        isLoading = true
        
        do {
            let loadedVerses = try await verseManager.getChapterVerses(
                book: currentBook,
                chapter: currentChapter,
                translation: SettingsViewModel.shared.preferredTranslation
            )
            
            self.verses = loadedVerses.map { item in
                Verse(
                    text: item.text,
                    translation: SettingsViewModel.shared.preferredTranslation,
                    reference: item.reference
                )
            }
            self.isLoading = false
            self.selectedVerses = []
            self.isMultiSelectMode = false
        } catch {
            self.verses = []
            self.isLoading = false
        }
    }
    
    func hasCommentary(for verse: Verse) async -> Bool {
        return await translationService.hasCommentary(
            for: verse.reference.book,
            chapter: verse.reference.chapter,
            verse: verse.reference.verse
        )
    }
    
    func handleVerseTap(_ verse: Verse) {
        if isMultiSelectMode {
            toggleVerseSelection(verse)
        } else if selectedVerse != nil && selectedVerse?.reference.id != verse.reference.id {
            // If we already have a selected verse and user taps a different verse,
            // enter multi-select mode with both verses
            isMultiSelectMode = true
            selectedVerses = []
            
            // Add the previously selected verse
            if let prevVerse = selectedVerse {
                selectedVerses.append(prevVerse)
            }
            
            // Add the newly tapped verse
            selectedVerses.append(verse)
            
            // Clear the single selection
            selectedVerse = nil
            showVerseActions = false
        } else {
            // Normal single verse selection
            selectedVerse = verse
            showVerseActions = false
        }
    }
    
    func handleVerseLongPress(_ verse: Verse) {
        if !isMultiSelectMode {
            isMultiSelectMode = true
            selectedVerses = [verse]
            // Clear any single verse selection when entering multi-select mode
            selectedVerse = nil
            showVerseActions = false
        } else {
            toggleVerseSelection(verse)
        }
    }
    
    func toggleVerseSelection(_ verse: Verse) {
        if isVerseSelected(verse) {
            selectedVerses.removeAll { $0.reference.id == verse.reference.id }
            
            // If no verses are selected, exit multi-select mode
            if selectedVerses.isEmpty {
                isMultiSelectMode = false
            }
        } else {
            selectedVerses.append(verse)
        }
    }
    
    func isVerseSelected(_ verse: Verse) -> Bool {
        if isMultiSelectMode {
            return selectedVerses.contains { $0.reference.id == verse.reference.id }
        } else {
            return selectedVerse?.reference.id == verse.reference.id
        }
    }
    
    func cancelMultiSelect() {
        isMultiSelectMode = false
        selectedVerses = []
    }
    
    func navigateToPreviousChapter() {
        isNavigating = true
        
        // Clear selections when navigating - without animation
        withAnimation(nil) {
            selectedVerse = nil
            selectedVerses = []
            isMultiSelectMode = false
        }
        
        if currentChapter > 1 {
            currentChapter -= 1
        } else {
            // Logic to go to previous book's last chapter
            if let index = BibleBooks.all.firstIndex(of: currentBook), index > 0 {
                let previousBook = BibleBooks.all[index - 1]
                currentBook = previousBook
                currentChapter = BibleBooks.chapterCounts[previousBook] ?? 1
            }
        }
        
        // Reset navigation flag after a longer delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isNavigating = false
        }
    }

    func navigateToNextChapter() {
        isNavigating = true
        
        // Clear selections when navigating - without animation
        withAnimation(nil) {
            selectedVerse = nil
            selectedVerses = []
            isMultiSelectMode = false
        }
        
        if let chapterCount = BibleBooks.chapterCounts[currentBook], currentChapter < chapterCount {
            currentChapter += 1
        } else {
            // Logic to go to next book's first chapter
            if let index = BibleBooks.all.firstIndex(of: currentBook), index < BibleBooks.all.count - 1 {
                let nextBook = BibleBooks.all[index + 1]
                currentBook = nextBook
                currentChapter = 1
            }
        }
        
        // Reset navigation flag after a longer delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.isNavigating = false
        }
    }
    
    func toggleBookmark() {
        let bookmarks = Bookmarks.shared
        
        if isMultiSelectMode {
            // Handle multiple verses
            for verse in selectedVerses {
                if bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
                    if let bookmark = bookmarks.bookmarks.first(where: {
                        $0.book == verse.reference.book &&
                        $0.chapter == verse.reference.chapter &&
                        $0.verse == verse.reference.verse
                    }) {
                        bookmarks.removeBookmark(withId: bookmark.id)
                    }
                } else {
                    bookmarks.addBookmark(
                        book: verse.reference.book,
                        chapter: verse.reference.chapter,
                        verse: verse.reference.verse,
                        text: verse.text
                    )
                }
            }
        } else if let verse = selectedVerse {
            // Handle single verse
            if bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
                if let bookmark = bookmarks.bookmarks.first(where: {
                    $0.book == verse.reference.book &&
                    $0.chapter == verse.reference.chapter &&
                    $0.verse == verse.reference.verse
                }) {
                    bookmarks.removeBookmark(withId: bookmark.id)
                }
            } else {
                bookmarks.addBookmark(
                    book: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse,
                    text: verse.text
                )
            }
        }
    }
    
    // Compare translations
    func showTranslationComparison() {
        guard selectedVerse != nil else { return }
        // Implementation depends on your app's navigation structure
        // This could post a notification or set a state variable
        // that triggers a sheet or navigation
    }
    
    // Highlight verse
    func toggleHighlight() {
        if isMultiSelectMode {
            // Handle multiple verses
            for verse in selectedVerses {
                userDataManager.toggleHighlight(verse.reference)
            }
        } else if let verse = selectedVerse {
            // Handle single verse
            userDataManager.toggleHighlight(verse.reference)
        }
    }
    
    // Add/edit note
    func showNoteEditor() {
        guard selectedVerse != nil else { return }
        // Implementation depends on your app's navigation structure
        // This could post a notification or set a state variable
        // that triggers a sheet or navigation
    }
    
    // Show image generator/picker
    func showImageOptions() {
        guard selectedVerse != nil else { return }
        showingImageOptions = true
        // Implementation depends on your app's navigation structure
        // This could post a notification or set a state variable
        // that triggers a sheet or navigation
    }
    
    func areAllVersesSelected() -> Bool {
        // Check if all verses are selected
        guard !verses.isEmpty else { return false }
        
        // If in multi-select mode, check if all verses are in the selectedVerses array
        if isMultiSelectMode {
            return selectedVerses.count == verses.count
        }
        
        return false
    }
    
    func selectAllVerses() {
        // Select all verses
        isMultiSelectMode = true
        selectedVerses = verses
    }
    
    func markLastVisibleVerse(_ verseNumber: Int) {
        lastVisibleVerse = verseNumber
    }
    
    private func persistLocation() {
        defaults.set(currentBook, forKey: lastBookKey)
        defaults.set(currentChapter, forKey: lastChapterKey)
        
        if let lastVerse = lastVisibleVerse ?? highlightedVerse {
            defaults.set(lastVerse, forKey: lastVerseKey)
        }
    }
}
