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
    @Published var pendingFocusReference: VerseReference? = nil
    @Published var focusedVerseID: String? = nil
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
        
#if DEBUG
        print("DEBUG VerseListViewModel.init startBook=\(startBook) startChapter=\(startChapter) startVerse=\(String(describing: startVerse))")
#endif

        self.currentBook = startBook
        self.currentChapter = startChapter
        self.highlightedVerse = startVerse
        if let startVerse {
            let ref = VerseReference(book: startBook, chapter: startChapter, verse: startVerse)
            self.pendingFocusReference = ref
            self.focusedVerseID = ref.id
        } else {
            self.pendingFocusReference = nil
            self.focusedVerseID = nil
        }
        self.lastVisibleVerse = startVerse
        
#if DEBUG
        print("DEBUG VerseListViewModel.init pendingFocusID=\(pendingFocusReference?.id ?? "nil")")
#endif

        persistLocation()
    }

    func applyDeepLink(book: String, chapter: Int, verse: Int?) async {
        isNavigating = true
        let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
#if DEBUG
        assertCanonicalBook(canonicalBook, context: "VerseListViewModel.applyDeepLink")
#endif
        currentBook = canonicalBook
        currentChapter = chapter
        if let verse, verse > 0 {
            highlightedVerse = verse
            let ref = VerseReference(book: canonicalBook, chapter: chapter, verse: verse)
            pendingFocusReference = ref
            focusedVerseID = ref.id
        } else {
            highlightedVerse = nil
            pendingFocusReference = nil
            focusedVerseID = nil
        }
        
#if DEBUG
        print("DEBUG applyDeepLink book=\(book) canonicalBook=\(canonicalBook) chapter=\(chapter) verse=\(String(describing: verse))")
#endif
        await loadVerses()
        isNavigating = false
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
        defer { isLoading = false }

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

            self.selectedVerses = []
            self.isMultiSelectMode = false
        } catch {
#if DEBUG
            print("DEBUG loadVerses FAILED book=\(currentBook) chapter=\(currentChapter) error=\(error)")
#endif
            self.verses = []
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
            return
        }

        guard let currentSelected = selectedVerse else {
            selectSingleVerse(verse)
            return
        }

        guard currentSelected.reference.id != verse.reference.id else {
            clearSelection()
            return
        }

        startMultiSelect(with: currentSelected, and: verse)
    }
    
    func toggleVerseSelection(_ verse: Verse) {
        if isVerseSelected(verse) {
            selectedVerses.removeAll { $0.reference.id == verse.reference.id }
            
            // If no verses are selected, exit multi-select mode
            if selectedVerses.isEmpty {
                clearSelection()
            }
        } else {
            selectedVerses.append(verse)
            sortSelectedVerses()
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
        clearSelection()
    }
    
    func navigateToPreviousChapter() {
        isNavigating = true
        
        // Clear selections when navigating - without animation
        withAnimation(nil) {
            selectedVerse = nil
            selectedVerses = []
            isMultiSelectMode = false
            highlightedVerse = nil
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

        // Reset stored verse so the next chapter starts at the top.
        lastVisibleVerse = 1

        Task { [weak self] in
            guard let self else { return }
            await self.loadVerses()
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
            highlightedVerse = nil
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

        // Reset stored verse so the next chapter starts at the top.
        lastVisibleVerse = 1

        Task { [weak self] in
            guard let self else { return }
            await self.loadVerses()
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
        selectedVerse = nil
        selectedVerses = verses.sorted { verseOrder(lhs: $0, rhs: $1) }
    }

    func beginMultiSelect(with verse: Verse) {
        isMultiSelectMode = true
        selectedVerse = nil
        selectedVerses = [verse]
        showVerseActions = false
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

    var orderedSelectedVerses: [Verse] {
        if isMultiSelectMode {
            return selectedVerses.sorted { verseOrder(lhs: $0, rhs: $1) }
        }

        guard let selectedVerse else { return [] }
        return [selectedVerse]
    }

    func selectedVersesTextBlock() -> String {
        selectedVersesTextBlock(includeAppLink: true)
    }

    func selectedVersesTextBlock(includeAppLink: Bool) -> String {
        var lines: [String] = []

        if let chapterReference = selectedChapterReference {
            lines.append(chapterReference)
        }

        lines.append(contentsOf: orderedSelectedVerses.map { verse in
            "\(verse.reference.verse). \(verse.text)"
        })

        if includeAppLink {
            lines.append("")
            lines.append("Read more: https://officialaavebible.com")
        }

        return lines.joined(separator: "\n")
    }

    private var selectedChapterReference: String? {
        guard let first = orderedSelectedVerses.first else { return nil }
        let verses = orderedSelectedVerses.map(\.reference.verse)
        guard let minVerse = verses.min(), let maxVerse = verses.max() else {
            return first.reference.displayString
        }

        if minVerse == maxVerse {
            return first.reference.displayString
        }

        return "\(first.reference.book) \(first.reference.chapter):\(minVerse)-\(maxVerse)"
    }

    private func selectSingleVerse(_ verse: Verse) {
        selectedVerse = verse
        selectedVerses = []
        isMultiSelectMode = false
        showVerseActions = false
    }

    private func startMultiSelect(with firstVerse: Verse, and secondVerse: Verse) {
        isMultiSelectMode = true
        selectedVerse = nil
        selectedVerses = [firstVerse, secondVerse]
        sortSelectedVerses()
        showVerseActions = false
    }

    private func clearSelection() {
        isMultiSelectMode = false
        selectedVerse = nil
        selectedVerses = []
        showVerseActions = false
    }

    private func sortSelectedVerses() {
        selectedVerses.sort { verseOrder(lhs: $0, rhs: $1) }
    }

    private func verseOrder(lhs: Verse, rhs: Verse) -> Bool {
        if lhs.reference.book != rhs.reference.book {
            return lhs.reference.book < rhs.reference.book
        }

        if lhs.reference.chapter != rhs.reference.chapter {
            return lhs.reference.chapter < rhs.reference.chapter
        }

        return lhs.reference.verse < rhs.reference.verse
    }
}
