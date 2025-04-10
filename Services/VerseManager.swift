import Foundation

@MainActor
class VerseManager: ObservableObject {
    static let shared = VerseManager()
    
    @Published private(set) var downloadedBooks: Set<String> = []
    @Published private(set) var downloadingBooks: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    
    private let fileManager = FileManager.default
    private let bibleAPI = BibleAPIService.shared
    
    private var documentsPath: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    init() {
        loadDownloadedBooks()
    }
    
    func getVerse(book: String, chapter: Int, verse: Int, translation: String) async throws -> String {
        // For AAVE translation, always use local JSON
        if translation.lowercased() == "aave" {
            return try await getLocalVerse(book: book, chapter: chapter, verse: verse, translation: translation)
        }
        
        // For other translations, try online first if not downloaded
        if !downloadedBooks.contains(book) {
            return try await bibleAPI.fetchVerse(
                book: book,
                chapter: chapter,
                verse: verse,
                translation: translation
            ).text
        }
        
        // If downloaded, use local storage
        return try await getLocalVerse(book: book, chapter: chapter, verse: verse, translation: translation)
    }
    
    func downloadBook(_ book: String, translation: String = "NET") async throws {
        guard !downloadingBooks.contains(book) else { return }
        guard !downloadedBooks.contains(book) else { return }
        
        downloadingBooks.insert(book)
        downloadProgress[book] = 0.0
        
        guard let bookData = chapterVerseCount[book] else {
            throw BibleError.invalidBook
        }
        
        var bookContent: [String: [String: String]] = [:]
        let totalChapters = bookData.count
        
        for (chapter, verseCount) in bookData {
            let verses = try await bibleAPI.fetchChapter(
                book: book,
                chapter: chapter,
                translation: translation
            )
            
            var chapterVerses: [String: String] = [:]
            for (index, verse) in verses.enumerated() {
                guard index < verseCount else { break }
                chapterVerses[String(index + 1)] = verse.text
            }
            
            bookContent[String(chapter)] = chapterVerses
            
            let progress = Double(chapter) / Double(totalChapters)
            downloadProgress[book] = progress
        }
        
        try await saveBookContent(book: book, content: bookContent)
        
        downloadingBooks.remove(book)
        downloadedBooks.insert(book)
        downloadProgress[book] = 1.0
        saveDownloadedBooks()
    }
    
    private func getLocalVerse(book: String, chapter: Int, verse: Int, translation: String) async throws -> String {
        guard let documentsPath = documentsPath else {
            throw BibleError.storageError
        }
        
        let bookFile = documentsPath.appendingPathComponent("\(book)_\(translation).json")
        guard fileManager.fileExists(atPath: bookFile.path) else {
            throw BibleError.verseNotFound
        }
        
        let data = try Data(contentsOf: bookFile)
        let verses = try JSONDecoder().decode([String: [String: String]].self, from: data)
        
        guard let chapterVerses = verses[String(chapter)],
              let verseText = chapterVerses[String(verse)] else {
            throw BibleError.verseNotFound
        }
        
        return verseText
    }
    
    private func saveBookContent(book: String, content: [String: [String: String]]) async throws {
        guard let documentsPath = documentsPath else {
            throw BibleError.storageError
        }
        
        let bookFile = documentsPath.appendingPathComponent("\(book).json")
        let data = try JSONEncoder().encode(content)
        try data.write(to: bookFile)
    }
    
    private func loadDownloadedBooks() {
        if let saved = UserDefaults.standard.array(forKey: "downloadedBooks") as? [String] {
            downloadedBooks = Set(saved)
        }
    }
    
    private func saveDownloadedBooks() {
        UserDefaults.standard.set(Array(downloadedBooks), forKey: "downloadedBooks")
    }
}