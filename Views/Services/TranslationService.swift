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
    
    // Books with complete AAVE translations
    var availableAAVEBooks = ["Genesis", "Exodus", "Leviticus", "Numbers", "Judges"]
    
    // All books that have AAVE files (even if empty/coming soon)
    let allAAVEBooks = bibleBooks.map { $0.name }
    
    private let verseManager = VerseManager.shared
    
    private init() {
        debugSpecificCommentary()
        loadCommentary()
    }
    
    private func loadCommentary() {
        // Load all available commentary files
        for book in allAAVEBooks {
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
        let shortNames = [
            "Genesis": "Gen", "Exodus": "Exo", "Leviticus": "Lev", "Numbers": "Num",
            "Deuteronomy": "Deu", "Joshua": "Jos", "Judges": "Judg", "Ruth": "Rut",
            "1 Samuel": "1Sam", "2 Samuel": "2Sam", "1 Kings": "1Kin", "2 Kings": "2Kin",
            "1 Chronicles": "1Chr", "2 Chronicles": "2Chr", "Ezra": "Ezr", "Nehemiah": "Neh",
            "Esther": "Est", "Job": "Job", "Psalms": "Psa", "Proverbs": "Pro",
            "Ecclesiastes": "Ecc", "Song of Solomon": "Son", "Isaiah": "Isa", "Jeremiah": "Jer",
            "Lamentations": "Lam", "Ezekiel": "Eze", "Daniel": "Dan", "Hosea": "Hos",
            "Joel": "Joe", "Amos": "Amo", "Obadiah": "Oba", "Jonah": "Jon",
            "Micah": "Mic", "Nahum": "Nah", "Habakkuk": "Hab", "Zephaniah": "Zep",
            "Haggai": "Hag", "Zechariah": "Zec", "Malachi": "Mal", "Matthew": "Mat",
            "Mark": "Mar", "Luke": "Luk", "John": "Joh", "Acts": "Act",
            "Romans": "Rom", "1 Corinthians": "1Cor", "2 Corinthians": "2Cor", "Galatians": "Gal",
            "Ephesians": "Eph", "Philippians": "Phi", "Colossians": "Col", "1 Thessalonians": "1The",
            "2 Thessalonians": "2The", "1 Timothy": "1Tim", "2 Timothy": "2Tim", "Titus": "Tit",
            "Philemon": "Phil", "Hebrews": "Heb", "James": "Jam", "1 Peter": "1Pet",
            "2 Peter": "2Pet", "1 John": "1Joh", "2 John": "2Joh", "3 John": "3Joh",
            "Jude": "Jud", "Revelation": "Rev"
        ]
        return shortNames[book] ?? book
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
                        
                        // Check if the file has actual content or is just an empty structure
                        let hasContent = verses.values.contains { chapter in
                            !chapter.isEmpty && chapter.values.contains { verse in
                                !verse.isEmpty && !verse.contains("Coming Soon")
                            }
                        }
                        
                        aaveTranslations[book] = verses
                        loaded = true
                        
                        // If this book has actual content, add it to availableAAVEBooks if not already there
                        if hasContent && !availableAAVEBooks.contains(book) {
                            print("DEBUG: \(book) has content but wasn't in availableAAVEBooks")
                            availableAAVEBooks.append(book)
                        }
                        
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
        return availableAAVEBooks.contains(book)
    }
    
    // Check if a book has an AAVE file (even if it's just a placeholder)
    func hasAAVEFile(for book: String) -> Bool {
        return aaveTranslations[book] != nil
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
    
    func searchVerses(query: String) async throws -> [SearchResult] {
        guard !query.isEmpty else { return [] }
        
        var results: [SearchResult] = []
        
        for (book, chapters) in aaveTranslations {
            // Only search in books with actual content
            if !isAAVEAvailable(for: book) {
                continue
            }
            
            for (chapterStr, verses) in chapters {
                guard let chapter = Int(chapterStr) else { continue }
                
                for (verseStr, aaveText) in verses {
                    guard let verse = Int(verseStr) else { continue }
                    
                    if aaveText.localizedCaseInsensitiveContains(query) {
                        let traditionalText = try await verseManager.getVerse(
                            book: book,
                            chapter: chapter,
                            verse: verse,
                            translation: "KJV"
                        )
                        
                        let result = SearchResult(
                            book: book,
                            chapter: chapter,
                            verse: verse,
                            aaveText: aaveText,
                            traditionalText: traditionalText
                        )
                        results.append(result)
                    }
                }
            }
        }
        
        return results
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
