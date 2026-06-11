import Foundation

struct ChapterCacheKey: Hashable {
    let book: String
    let chapter: Int
    let translation: String

    init(book: String, chapter: Int, translation: String) {
        self.book = book
        self.chapter = chapter
        self.translation = translation.uppercased()
    }
}

struct ChapterVerseCache {
    let capacity: Int
    private(set) var storage: [ChapterCacheKey: [VerseItem]] = [:]
    private var recency: [ChapterCacheKey] = []

    init(capacity: Int) {
        self.capacity = max(1, capacity)
    }

    mutating func value(for key: ChapterCacheKey) -> [VerseItem]? {
        guard let value = storage[key] else { return nil }
        markRecentlyUsed(key)
        return value
    }

    mutating func insert(_ value: [VerseItem], for key: ChapterCacheKey) {
        storage[key] = value
        markRecentlyUsed(key)

        while recency.count > capacity, let leastRecent = recency.first {
            recency.removeFirst()
            storage.removeValue(forKey: leastRecent)
        }
    }

    mutating func removeAll() {
        storage.removeAll()
        recency.removeAll()
    }

    func contains(_ key: ChapterCacheKey) -> Bool {
        storage[key] != nil
    }

    private mutating func markRecentlyUsed(_ key: ChapterCacheKey) {
        recency.removeAll { $0 == key }
        recency.append(key)
    }
}

@MainActor
class VerseManager: ObservableObject {
    static let shared = VerseManager()
    
    @Published private(set) var downloadedBooks: Set<String> = []
    @Published private(set) var downloadingBooks: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    
    private let fileManager = FileManager.default
    private let bibleAPI = BibleAPIService.shared
    private let cache = NSCache<NSString, NSString>()
    private var chapterCache = ChapterVerseCache(capacity: 3)
    
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
    
    func getChapterVerses(book: String, chapter: Int, translation: String) async throws -> [VerseItem] {
        let cacheKey = ChapterCacheKey(book: book, chapter: chapter, translation: translation)
        if let cachedVerses = chapterCache.value(for: cacheKey) {
            return cachedVerses
        }

        if translation.uppercased() == "AAVE" {
            let verses = try TranslationService.shared.getAAVEChapter(book: book, chapter: chapter)
            chapterCache.insert(verses, for: cacheKey)
            return verses
        }

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
        
        chapterCache.insert(verses, for: cacheKey)
        return verses
    }

    func preloadAdjacentChapters(book: String, chapter: Int, translation: String) async {
        for reference in Self.adjacentChapterReferences(book: book, chapter: chapter) {
            guard !Task.isCancelled else { return }
            guard translation.uppercased() == "AAVE" || downloadedBooks.contains(reference.book) else {
                continue
            }

            do {
                _ = try await getChapterVerses(
                    book: reference.book,
                    chapter: reference.chapter,
                    translation: translation
                )
            } catch {
#if DEBUG
                print("DEBUG: Adjacent chapter preload failed for \(reference.book) \(reference.chapter): \(error)")
#endif
            }
        }
    }

    static func adjacentChapterReferences(book: String, chapter: Int) -> [(book: String, chapter: Int)] {
        guard let bookIndex = BibleBooks.all.firstIndex(of: book),
              let chapterCount = BibleBooks.chapterCounts[book],
              chapter >= 1,
              chapter <= chapterCount else {
            return []
        }

        var references: [(book: String, chapter: Int)] = []

        if chapter > 1 {
            references.append((book, chapter - 1))
        } else if bookIndex > 0 {
            let previousBook = BibleBooks.all[bookIndex - 1]
            references.append((previousBook, BibleBooks.chapterCounts[previousBook] ?? 1))
        }

        if chapter < chapterCount {
            references.append((book, chapter + 1))
        } else if bookIndex < BibleBooks.all.count - 1 {
            references.append((BibleBooks.all[bookIndex + 1], 1))
        }

        return references
    }

#if DEBUG
    func resetChapterCacheForTesting() {
        chapterCache.removeAll()
    }

    func isChapterCachedForTesting(book: String, chapter: Int, translation: String) -> Bool {
        chapterCache.contains(ChapterCacheKey(book: book, chapter: chapter, translation: translation))
    }

    var chapterCacheCountForTesting: Int {
        chapterCache.storage.count
    }
#endif
}
