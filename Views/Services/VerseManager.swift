import Foundation

@MainActor
class VerseManager: ObservableObject {
    static let shared = VerseManager()
    
    @Published private(set) var downloadedBooks: Set<String> = []
    @Published private(set) var downloadingBooks: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    
    private let fileManager = FileManager.default
    private let bibleAPI = BibleAPIService.shared
    private let cache = NSCache<NSString, NSString>()
    
    private var documentsPath: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    init() {
        loadDownloadedBooks()
        validateDownloadedBooks()
    }
    
    func getVerse(book: String, chapter: Int, verse: Int, translation: String) async throws -> String {
        let cacheKey = "\(book)_\(chapter)_\(verse)_\(translation)" as NSString
        print("DEBUG: VerseManager fetching \(book) \(chapter):\(verse) [\(translation)]")
        
        // Check cache first
        if let cachedVerse = cache.object(forKey: cacheKey) {
            return String(cachedVerse)
        }
        
        // For AAVE translation, always use TranslationService
        if translation.uppercased() == "AAVE" {
            return try await TranslationService.shared.getVerseTranslation(
                for: book,
                chapter: chapter,
                verse: verse,
                translation: translation
            )
        }
        
        do {
            // Try to get from local storage first if downloaded
            if downloadedBooks.contains(book) {
                do {
                    let verseText = try await getLocalVerse(book: book, chapter: chapter, verse: verse, translation: translation)
                    cache.setObject(verseText as NSString, forKey: cacheKey)
                    return verseText
                } catch {
                    print("DEBUG: Local verse fetch failed: \(error)")
                }
            }
            
            // If not downloaded or local fetch fails, try online
            let result = try await bibleAPI.fetchVerse(
                book: book,
                chapter: chapter,
                verse: verse,
                translation: translation
            )
            cache.setObject(result.text as NSString, forKey: cacheKey)
            return result.text
        } catch {
            print("DEBUG: Error fetching verse: \(error)")
            throw error
        }
    }
    
    private func getLocalVerse(book: String, chapter: Int, verse: Int, translation: String) async throws -> String {
        guard let documentsPath = documentsPath else {
            throw BibleError.storageError
        }
        
        let filename = getBookFilename(book: book, translation: translation)
        let bookFile = documentsPath.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: bookFile.path) else {
            print("DEBUG: File not found: \(bookFile.path)")
            throw BibleError.verseNotFound
        }
        
        do {
            let data = try Data(contentsOf: bookFile)
            let verses = try JSONDecoder().decode([String: [String: String]].self, from: data)
            
            guard let chapterVerses = verses[String(chapter)],
                  let verseText = chapterVerses[String(verse)] else {
                print("DEBUG: Verse not found in JSON: \(book) \(chapter):\(verse)")
                throw BibleError.verseNotFound
            }
            
            return verseText
        } catch {
            print("DEBUG: Error reading local verse: \(error)")
            throw BibleError.verseNotFound
        }
    }
    
    private func getBookURL(book: String, translation: String) -> URL? {
        guard let documentsPath = documentsPath else { return nil }
        return documentsPath
            .appendingPathComponent("Books")
            .appendingPathComponent(translation)
            .appendingPathComponent("\(book).json")
    }
    
    func downloadBook(_ book: String, translation: String = "NET") async throws {
        guard !downloadingBooks.contains(book) else { return }
        guard !downloadedBooks.contains(book) else { return }
        
        downloadingBooks.insert(book)
        downloadProgress[book] = 0.0
        
        defer {
            downloadingBooks.remove(book)
            downloadProgress[book] = 1.0
        }
        
        guard let bookData = chapterVerseCount[book] else {
            throw BibleError.invalidBook
        }
        
        var bookContent: [String: [String: String]] = [:]
        let totalChapters = bookData.count
        
        for (chapter, _) in bookData {
            do {
                let verses = try await bibleAPI.fetchChapter(
                    book: book,
                    chapter: chapter,
                    translation: translation
                )
                
                var chapterVerses: [String: String] = [:]
                for verse in verses {
                    chapterVerses[String(verse.reference.verse)] = verse.text
                }
                
                bookContent[String(chapter)] = chapterVerses
                
                let progress = Double(chapter) / Double(totalChapters)
                downloadProgress[book] = progress
            } catch {
                print("DEBUG: Error downloading chapter \(chapter): \(error)")
                throw BibleError.networkError
            }
        }
        
        try await saveBookContent(book: book, content: bookContent, translation: translation)
        
        downloadedBooks.insert(book)
        saveDownloadedBooks()
    }
    
    private func saveBookContent(book: String, content: [String: [String: String]], translation: String) async throws {
        guard let documentsPath = documentsPath else {
            throw BibleError.storageError
        }
        
        let filename = getBookFilename(book: book, translation: translation)
        let bookFile = documentsPath.appendingPathComponent(filename)
        
        let data = try JSONEncoder().encode(content)
        try data.write(to: bookFile)
    }
    
    private func getBookFilename(book: String, translation: String) -> String {
        "\(book)_\(translation.uppercased()).json"
    }
    
    private func loadDownloadedBooks() {
        if let data = UserDefaults.standard.data(forKey: "downloadedBooks"),
           let books = try? JSONDecoder().decode(Set<String>.self, from: data) {
            downloadedBooks = books
        }
    }
    
    private func saveDownloadedBooks() {
        if let data = try? JSONEncoder().encode(downloadedBooks) {
            UserDefaults.standard.set(data, forKey: "downloadedBooks")
        }
    }
    
    private func validateDownloadedBooks() {
        guard let documentsPath = documentsPath else { return }
        
        var validatedBooks: Set<String> = []
        
        for book in downloadedBooks {
            let netFile = documentsPath.appendingPathComponent(getBookFilename(book: book, translation: "NET"))
            let aaveFile = documentsPath.appendingPathComponent(getBookFilename(book: book, translation: "AAVE"))
            
            if fileManager.fileExists(atPath: netFile.path) || fileManager.fileExists(atPath: aaveFile.path) {
                validatedBooks.insert(book)
            }
        }
        
        downloadedBooks = validatedBooks
        saveDownloadedBooks()
    }
    
    func refreshAvailableBooks() async {
        validateDownloadedBooks()
    }
    func searchVerses(_ query: String, translation: String) async throws -> [SearchResult] {
        return try await TranslationService.shared.searchVerses(query: query)
    }
    
    func getChapterVerses(book: String, chapter: Int, translation: String) async throws -> [VerseItem] {
        guard let verseCount = chapterVerseCount[book]?[chapter] else {
            throw BibleError.invalidChapter
        }
        
        var verses: [VerseItem] = []
        for verse in 1...verseCount {
            let text = try await getVerse(book: book, chapter: chapter, verse: verse, translation: translation)
            let reference = VerseReference(book: book, chapter: chapter, verse: verse)
            verses.append(VerseItem(
                number: verse,
                text: text,
                reference: reference
            ))
        }
        
        return verses
    }
}
