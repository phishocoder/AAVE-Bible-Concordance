import Foundation

@MainActor
class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    @Published var isLoaded: Bool = false
    @Published var isOnline: Bool = true
    @Published var loadingProgress: Double = 0.0
    
    // Core data stores
    private var aaveTranslations: [String: [String: [String: String]]] = [:]
    private var commentary: [String: String] = [:]
    private var searchIndex: [String: Set<VerseReference>] = [:]
    
    // Books with bundled AAVE JSON files
    private(set) var availableAAVEBooks: [String] = []

    var searchCoverageDescription: String {
        "AAVE search covers: \(availableAAVEBooks.count) books"
    }
    
    // Canonical list of all books (used for commentary loading)
    let allAAVEBooks = bibleBooks.map { $0.name }
    
    private let verseManager = VerseManager.shared
    
    private init() {
        availableAAVEBooks = discoverAAVEBooks()
        debugSpecificCommentary()
        loadCommentary()
    }
    
    private func loadCommentary() {
        // Load all available commentary files
        for book in availableAAVEBooks {
            let shortName = getShortBookName(book)
            let possiblePaths = [
                Bundle.main.url(forResource: "Commentary_\(shortName)", withExtension: "json", subdirectory: "Commentary"),
                Bundle.main.url(forResource: "Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Resources/Commentary/Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Commentary/Commentary_\(shortName)", withExtension: "json"),
            ]
            
            print("DEBUG: Attempting to load Commentary_\(shortName).json")
            
            for (index, potentialURL) in possiblePaths.enumerated() {
                if let url = potentialURL {
                    print("DEBUG: Trying path \(index + 1): \(url.path)")
                    
                    do {
                        let data = try Data(contentsOf: url)
                        let decoder = JSONDecoder()
                        let commentaryData = try decoder.decode([String: [String: [String: String]]].self, from: data)
                        
                        print("DEBUG: Loaded JSON structure: \(commentaryData.keys)")
                        
                        for (bookName, chapters) in commentaryData {
                            print("DEBUG: Processing book: \(bookName)")
                            for (chapter, verses) in chapters {
                                print("DEBUG: Processing chapter: \(chapter)")
                                for (verse, comment) in verses {
                                    let key = "\(bookName)_\(chapter)_\(verse)"
                                    commentary[key] = comment
                                    print("DEBUG: Added commentary for key: \(key)")
                                }
                            }
                        }
                        
                        print("DEBUG: Commentary loaded for \(shortName)")
                        break
                    } catch {
                        print("DEBUG: Failed to load from path \(index + 1): \(error)")
                    }
                }
            }
        }
        
        print("DEBUG: Final commentary count: \(commentary.count)")
        print("DEBUG: Sample keys: \(Array(commentary.keys).prefix(5))")
    }
    
    private func getShortBookName(_ book: String) -> String {
        return BibleBooks.shortNames[book] ?? book
    }

    private func discoverAAVEBooks() -> [String] {
        guard let resourceURL = Bundle.main.resourceURL else { return [] }
        let fileManager = FileManager.default
        let suffix = "_AAVE"
        var found = Set<String>()

        if let enumerator = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
            for case let url as URL in enumerator {
                guard url.pathExtension == "json" else { continue }
                let baseName = url.deletingPathExtension().lastPathComponent
                guard baseName.hasSuffix(suffix) else { continue }
                let rawName = String(baseName.dropLast(suffix.count))
                let canonical = BookNameNormalizer.canonicalBookName(rawName) ?? rawName
                found.insert(canonical)
            }
        }

        let ordered = BibleBooks.all.filter { found.contains($0) }
        let extras = found.subtracting(ordered)
        return ordered + extras.sorted()
    }
    
    func loadTranslations() async throws {
        guard !isLoaded else { return }
        
        do {
            try await loadAAVETranslations()
            try await buildSearchIndex()
            await MainActor.run {
                isLoaded = true
            }
        } catch {
            await MainActor.run {
                isLoaded = false
            }
            throw error
        }
    }
    
    private func cleanAndValidateJSON(_ data: Data) throws -> Data {
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw BibleError.invalidData
        }
        // Remove any BOM or invalid characters
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Remove BOM
        
        guard let cleanedData = cleanedString.data(using: .utf8) else {
            throw BibleError.invalidData
        }
        
        return cleanedData
    }
    
    private func loadAAVETranslations() async throws {
        // Load all available AAVE books
        for book in allAAVEBooks {
            print("Attempting to load \(book)")
            
            let possiblePaths = [
                "\(book)-AAVE",
                "\(book)_AAVE",
                "AAVE/\(book)",
                book,
                "Books/Old Testament/\(book)_AAVE",
                "Books/New Testament/\(book)_AAVE",
                "Resources/Books/Old Testament/\(book)_AAVE",
                "Resources/Books/New Testament/\(book)_AAVE"
            ]
            
            var loaded = false
            
            for path in possiblePaths {
                if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                    print("Found resource at path: \(path)")
                    
                    do {
                        let data = try Data(contentsOf: url)
                        let cleanedData = try cleanAndValidateJSON(data)
                        
                        let decoder = JSONDecoder()
                        let verses = try decoder.decode([String: [String: String]].self, from: cleanedData)
                        
                        aaveTranslations[book] = verses
                        loaded = true
                        
                        break
                    } catch {
                        print("Failed to load \(path): \(error)")
                        continue
                    }
                }
            }
            
            // If we couldn't load the file, create an empty structure for this book
            if !loaded {
                print("DEBUG: Creating empty structure for \(book)")
                aaveTranslations[book] = [:]
            }
        }
    }
    
    private func buildSearchIndex() async throws {
        searchIndex.removeAll()
        
        for (book, chapters) in aaveTranslations {
            // Only index books with actual content
            if !isAAVEAvailable(for: book) {
                continue
            }
            
            for (chapter, verses) in chapters {
                for (verse, text) in verses {
                    let words = text.lowercased().split(separator: " ")
                    let reference = VerseReference(
                        book: book,
                        chapter: Int(chapter) ?? 0,
                        verse: Int(verse) ?? 0
                    )
                    
                    for word in words {
                        searchIndex[String(word), default: []].insert(reference)
                    }
                }
            }
        }
    }
    
    // Check if AAVE translation is available with actual content for a book
    func isAAVEAvailable(for book: String) -> Bool {
        let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
        return availableAAVEBooks.contains(canonicalBook)
    }
    
    // Check if a book has an AAVE file (even if it's just a placeholder)
    func hasAAVEFile(for book: String) -> Bool {
        let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
        return availableAAVEBooks.contains(canonicalBook)
    }
    
    func getVerseTranslation(for book: String, chapter: Int, verse: Int, translation: String) async throws -> String {
        if translation.uppercased() == "AAVE" {
            // If the book isn't in our available list but has a file, return "Coming Soon"
            if !isAAVEAvailable(for: book) && hasAAVEFile(for: book) {
                return "Coming Soon - AAVE Translation"
            }
            
            guard let bookVerses = aaveTranslations[book],
                  let chapterVerses = bookVerses[String(chapter)],
                  let verseText = chapterVerses[String(verse)] else {
                throw BibleError.verseNotFound
            }
            
            // If the verse exists but is empty, return "Coming Soon"
            if verseText.isEmpty {
                return "Coming Soon - AAVE Translation"
            }
            
            return verseText
        } else {
            return try await verseManager.getVerse(
                book: book,
                chapter: chapter,
                verse: verse,
                translation: translation
            )
        }
    }
    
    func getVerseCommentary(for book: String, chapter: Int, verse: Int) -> String? {
        // Convert chapter and verse to strings to match the JSON structure
        let key = "\(book)_\(String(chapter))_\(String(verse))"
        let result = commentary[key]
        print("DEBUG: Getting commentary for \(key): \(result != nil)")
        return result
    }
    
    func hasCommentary(for book: String, chapter: Int, verse: Int) -> Bool {
        // Convert chapter and verse to strings to match the JSON structure
        let key = "\(book)_\(String(chapter))_\(String(verse))"
        let result = commentary[key] != nil
        print("DEBUG: Checking commentary for \(key): \(result)")
        return result
    }
    
    func getVerseCount(for book: String, chapter: Int, translation: String) async throws -> Int {
        if translation.uppercased() == "AAVE" {
            guard let bookVerses = aaveTranslations[book],
                  let chapterVerses = bookVerses[String(chapter)] else {
                throw BibleError.chapterNotFound
            }
            return chapterVerses.count
        } else {
            // For other translations, check the chapter-verse count dictionary
            guard let bookData = chapterVerseCount[book],
                  let verseCount = bookData[chapter] else {
                throw BibleError.chapterNotFound
            }
            return verseCount
        }
    }
    
    func searchAAVEScripture(
        query: String,
        limit: Int = 50
    ) async throws -> SearchResultPage {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty(limit: limit) }
        
        if let reference = SearchQueryParser.parseReference(from: trimmed) {
            let canonicalBook = BookNameNormalizer.canonicalBookName(reference.book) ?? reference.book
            if reference.chapter == nil {
                let result = SearchResult(
                        book: canonicalBook,
                        chapter: nil,
                        verse: nil,
                        kind: .book,
                        aaveText: "",
                        traditionalText: ""
                    )
                return SearchResultPage(results: [result], totalCount: 1, limit: limit)
            }
            guard let chapter = reference.chapter else { return .empty(limit: limit) }
            if let verse = reference.verse {
                let verseReference = VerseReference(
                    book: canonicalBook,
                    chapter: chapter,
                    verse: verse
                )
                if let specific = try await searchByReference(verseReference) {
                    return SearchResultPage(results: [specific], totalCount: 1, limit: limit)
                }
                return .empty(limit: limit)
            }

            let chapterKey = String(chapter)
            if let chapterVerses = aaveTranslations[canonicalBook]?[chapterKey],
               !chapterVerses.isEmpty {
                let sortedVerses = chapterVerses.keys.compactMap(Int.init).sorted()
                let results: [SearchResult] = sortedVerses
                    .prefix(max(0, limit))
                    .compactMap { verseNumber -> SearchResult? in
                    guard let text = chapterVerses[String(verseNumber)] else { return nil }
                    return SearchResult(
                        book: canonicalBook,
                        chapter: chapter,
                        verse: verseNumber,
                        kind: .verse,
                        aaveText: text,
                        traditionalText: ""
                    )
                    }
                return SearchResultPage(
                    results: results,
                    totalCount: sortedVerses.count,
                    limit: limit
                )
            }

            let result = SearchResult(
                    book: canonicalBook,
                    chapter: chapter,
                    verse: nil,
                    kind: .chapter,
                    aaveText: "",
                    traditionalText: ""
                )
            return SearchResultPage(results: [result], totalCount: 1, limit: limit)
        }
        
        let translationsSnapshot = aaveTranslations
        let availableBooks = Set(availableAAVEBooks)
        
        return await Task.detached(priority: .userInitiated) {
            var candidates: [SearchResult] = []
            
            for (book, chapters) in translationsSnapshot where availableBooks.contains(book) {
                for (chapterStr, verses) in chapters {
                    guard let chapter = Int(chapterStr) else { continue }
                    
                    for (verseStr, aaveText) in verses {
                        guard let verse = Int(verseStr) else { continue }
                        
                        candidates.append(
                            SearchResult(
                                book: book,
                                chapter: chapter,
                                verse: verse,
                                kind: .verse,
                                aaveText: aaveText,
                                traditionalText: ""
                            )
                        )
                    }
                }
            }
            
            // The existing token index is punctuation-sensitive and can't preserve phrase or
            // partial-token ranking, so this MVP ranks a stable in-memory snapshot instead.
            return SearchResultRanker.rankedPage(
                query: trimmed,
                candidates: candidates,
                limit: limit
            )
        }.value
    }

    func searchVerses(query: String) async throws -> [SearchResult] {
        try await searchAAVEScripture(query: query, limit: .max).results
    }
    
    private func searchByReference(_ reference: VerseReference) async throws -> SearchResult? {
        let aaveText: String
        do {
            aaveText = try await getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "AAVE"
            )
        } catch BibleError.verseNotFound {
            aaveText = "Coming Soon - AAVE Translation"
        } catch {
            throw error
        }
        
        return SearchResult(
            book: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            kind: .verse,
            aaveText: aaveText,
            traditionalText: ""
        )
    }
    
    // Add this function to your TranslationService class
    private func debugSpecificCommentary() {
        // Test a working book (Genesis) and the problematic book (Judges)
        let testBooks = ["Gen", "Judg"]
        
        for shortName in testBooks {
            print("\n==== DEBUGGING \(shortName) COMMENTARY ====")
            
            let possiblePaths = [
                Bundle.main.url(forResource: "Commentary_\(shortName)", withExtension: "json", subdirectory: "Commentary"),
                Bundle.main.url(forResource: "Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Resources/Commentary/Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Commentary/Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Resources/Commentary/Old Testament/Commentary_\(shortName)", withExtension: "json"),
                Bundle.main.url(forResource: "Resources/Commentary/New Testament/Commentary_\(shortName)", withExtension: "json")
            ]
            
            for (index, potentialURL) in possiblePaths.enumerated() {
                if let url = potentialURL {
                    print("Path \(index + 1) exists: \(url.path)")
                    
                    // Check if file exists
                    if FileManager.default.fileExists(atPath: url.path) {
                        print("File exists at: \(url.path)")
                        
                        do {
                            let data = try Data(contentsOf: url)
                            print("File size: \(data.count) bytes")
                            
                            // Try to parse as raw JSON first
                            if let json = try? JSONSerialization.jsonObject(with: data) {
                                print("Valid JSON structure")
                                
                                // Check top-level keys
                                if let dict = json as? [String: Any] {
                                    print("Top-level keys: \(dict.keys.joined(separator: ", "))")
                                    
                                    // For Judges specifically, check if it has the expected book name
                                    if shortName == "Judg" {
                                        if dict["Judges"] != nil {
                                            print("✅ Contains 'Judges' key")
                                        } else {
                                            print("❌ Missing 'Judges' key")
                                        }
                                    }
                                }
                            } else {
                                print("❌ INVALID JSON")
                            }
                        } catch {
                            print("Error reading file: \(error)")
                        }
                    } else {
                        print("File does NOT exist at: \(url.path)")
                    }
                } else {
                    print("Path \(index + 1) is nil")
                }
            }
        }
    }
    // Add this function to your TranslationService class
    func testJudgesCommentary() {
        print("\n==== DIRECT TEST OF JUDGES COMMENTARY ====")
        
        // Try to load the file directly with its full path
        if let url = Bundle.main.url(forResource: "Commentary_Judg", withExtension: "json", subdirectory: "Resources/Commentary/Old Testament") {
            print("Found Judges commentary at: \(url.path)")
            
            do {
                let data = try Data(contentsOf: url)
                print("File size: \(data.count) bytes")
                
                // Try to parse as raw JSON first
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Valid JSON with keys: \(json.keys.joined(separator: ", "))")
                    
                    // Try to decode with the expected structure
                    let decoder = JSONDecoder()
                    let commentaryData = try decoder.decode([String: [String: [String: String]]].self, from: data)
                    print("Successfully decoded with structure: \(commentaryData.keys)")
                    
                    // Test a specific verse
                    if let judgesBook = commentaryData["Judges"],
                       let chapter1 = judgesBook["1"],
                       let verse1 = chapter1["1"] {
                        print("Found Judges 1:1 commentary: \(verse1)")
                        
                        // Test adding to the commentary dictionary
                        let key = "Judges_1_1"
                        commentary[key] = verse1
                        print("Added to commentary dictionary: \(commentary[key] != nil)")
                    }
                } else {
                    print("Failed to parse JSON")
                }
            } catch {
                print("Error reading/parsing file: \(error)")
            }
        } else {
            print("Could not find Judges commentary file")
            
            // List all files in the Resources directory to see what's available
            if let resourceURL = Bundle.main.resourceURL {
                print("Listing files in resource directory:")
                do {
                    let resourceContents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
                    for item in resourceContents {
                        print("- \(item.lastPathComponent)")
                    }
                } catch {
                    print("Error listing resources: \(error)")
                }
            }
        }
    }


    // New method to get available translations for a book
    func getAvailableTranslations(for book: String) -> [String] {
        var translations = ["NET"] // NET is always available
        
        if isAAVEAvailable(for: book) {
            translations.append("AAVE")
        }
        
        return translations
        
        // Add these methods to your TranslationService class

        func isAAVEAvailable(for book: String) -> Bool {
            return availableAAVEBooks.contains(book)
        }

        func hasAAVEFile(for book: String) -> Bool {
            return allAAVEBooks.contains(book)
        }

        func getAvailableBooks(for translation: String) -> [String] {
            if translation.uppercased() == "AAVE" {
                return availableAAVEBooks
            } else {
                // For other translations, assume all books are available
                return bibleBooks.map { $0.name }
            }
        }
    }
}
