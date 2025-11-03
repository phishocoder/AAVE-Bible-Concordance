import Foundation

@MainActor
class UserDataManager: ObservableObject {
    static let shared = UserDataManager()
    
    @Published private(set) var history: [VerseReference] = []
    @Published var notes: [String: String] = [:]
    @Published var lastReadVerse: VerseReference?
    @Published var chaptersRead: Set<String> = []
    
    private let historyKey = "readingHistory"
    private let bookmarksKey = "bookmarks"
    private let notesKey = "verseNotes"
    private let lastReadVerseKey = "lastReadVerse"
    private let chaptersReadKey = "chaptersRead"
    private let maxHistoryItems = 100
    
    private let highlightManager: HighlightManager
    private let bookmarks: Bookmarks

    private init() {
        self.highlightManager = HighlightManager.shared
        self.bookmarks = Bookmarks.shared
        loadHistory()
        loadNotes()
        loadLastReadVerse()
        loadChaptersRead()
    }
    
    func addToHistory(_ reference: VerseReference) {
        history.removeAll { $0.id == reference.id }
        history.insert(reference, at: 0)
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        saveHistory()
    }
    
    func saveNote(_ text: String, for reference: VerseReference) {
        notes[reference.id] = text
        saveNotes()
    }
    
    func getNote(for reference: VerseReference) -> String {
        return notes[reference.id] ?? ""
    }
    
    func removeNote(for reference: VerseReference) {
        notes.removeValue(forKey: reference.id)
        saveNotes()
    }
    
    // Highlight-related methods
    func isHighlighted(_ reference: VerseReference) -> Bool {
        highlightManager.isHighlighted(reference)
    }
    
    func toggleHighlight(_ reference: VerseReference) {
        highlightManager.toggleHighlight(reference)
    }
    
    // Add methods to update and load lastReadVerse
    func updateLastReadVerse(_ reference: VerseReference) {
        lastReadVerse = reference
        saveLastReadVerse()
    }
    
    private func loadLastReadVerse() {
        if let data = UserDefaults.standard.data(forKey: lastReadVerseKey),
           let decoded = try? JSONDecoder().decode(VerseReference.self, from: data) {
            lastReadVerse = decoded
        }
    }
    
    private func saveLastReadVerse() {
        if let reference = lastReadVerse,
           let encoded = try? JSONEncoder().encode(reference) {
            UserDefaults.standard.set(encoded, forKey: lastReadVerseKey)
        }
    }
    
    // Add methods to track read chapters
    func markChapterAsRead(book: String, chapter: Int) {
        let chapterKey = "\(book)_\(chapter)"
        chaptersRead.insert(chapterKey)
        saveChaptersRead()
    }
    
    func isChapterRead(book: String, chapter: Int) -> Bool {
        let chapterKey = "\(book)_\(chapter)"
        return chaptersRead.contains(chapterKey)
    }
    
    private func loadChaptersRead() {
        if let data = UserDefaults.standard.data(forKey: chaptersReadKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            chaptersRead = decoded
        }
    }
    
    private func saveChaptersRead() {
        if let encoded = try? JSONEncoder().encode(chaptersRead) {
            UserDefaults.standard.set(encoded, forKey: chaptersReadKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([VerseReference].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            notes = decoded
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func clearNotes() {
        notes.removeAll()
        saveNotes()
    }
    
    func clearChaptersRead() {
        chaptersRead.removeAll()
        saveChaptersRead()
    }
}
