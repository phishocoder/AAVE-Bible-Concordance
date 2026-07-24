//
//  BibleModelsTests.swift
//  AAVE Bible ConcordanceTests
//
//  Created by Phil Shobo on 3/8/25.
//

import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class BibleModelsTests: XCTestCase {
    
    // MARK: - Verse Tests
    func testVerseInitialization() {
        let reference = VerseReference(book: "John", chapter: 3, verse: 16)
        let verse = Verse(
            text: "For God so loved the world...",
            translation: "KJV",
            reference: reference
        )
        
        XCTAssertEqual(verse.reference.id, "John_3_16")
        XCTAssertEqual(verse.reference.book, "John")
        XCTAssertEqual(verse.reference.chapter, 3)
        XCTAssertEqual(verse.reference.verse, 16)
        XCTAssertEqual(verse.text, "For God so loved the world...")
        XCTAssertEqual(verse.translation, "KJV")
    }
    
    func testVerseCoding() throws {
        let reference = VerseReference(
            book: "John",
            chapter: 3,
            verse: 16,
            timestamp: Date(timeIntervalSince1970: 1_741_435_200)
        )
        let original = Verse(
            text: "For God so loved the world...",
            translation: "KJV",
            reference: reference
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Verse.self, from: data)
        
        XCTAssertEqual(decoded, original)
    }
    
    // MARK: - Bundled Translation Tests
    func testBundledAAVETranslationLoads() async throws {
        let service = TranslationService.shared
        try await service.loadTranslations()

        let text = try await service.getVerseTranslation(
            for: "John",
            chapter: 3,
            verse: 16,
            translation: "AAVE"
        )

        XCTAssertFalse(text.isEmpty)
        XCTAssertNotEqual(text, "Coming Soon - AAVE Translation")
    }

    func testDuplicateScriptureIsNotExposedAsCommentary() async throws {
        let service = TranslationService.shared
        try await service.loadTranslations()

        for verse in 1...17 {
            XCTAssertFalse(
                service.hasCommentary(for: "Leviticus", chapter: 1, verse: verse),
                "Leviticus 1:\(verse) must not expose duplicated scripture as commentary"
            )
            XCTAssertNil(
                service.getVerseCommentary(for: "Leviticus", chapter: 1, verse: verse)
            )
        }

        XCTAssertFalse(service.hasCommentary(for: "1 Corinthians", chapter: 3, verse: 23))
        XCTAssertFalse(service.hasCommentary(for: "1 Corinthians", chapter: 13, verse: 6))
        XCTAssertTrue(
            service.hasCommentary(for: "Leviticus", chapter: 2, verse: 1),
            "Valid nearby commentary should remain available"
        )
    }
    
    // MARK: - BibleBook Tests
    func testBibleBookIdentifiable() {
        let book = BibleBook(name: "Genesis", chapters: 50, testament: .old)
        XCTAssertEqual(book.id, "Genesis")
    }
    
    func testbibleBooksCompleteness() {
        // Test Old Testament books count
        let oldTestamentBooks = bibleBooks.filter { $0.testament == .old }
        XCTAssertEqual(oldTestamentBooks.count, 39, "Should have 39 Old Testament books")
        
        // Test New Testament books count
        let newTestamentBooks = bibleBooks.filter { $0.testament == .new }
        XCTAssertEqual(newTestamentBooks.count, 27, "Should have 27 New Testament books")
        
        // Test total books count
        XCTAssertEqual(bibleBooks.count, 66, "Should have 66 total books")
    }
    
    func testSpecificBooksExistence() {
        // Test some key books exist
        XCTAssertTrue(bibleBooks.contains(where: { $0.name == "Genesis" && $0.testament == .old }))
        XCTAssertTrue(bibleBooks.contains(where: { $0.name == "Psalms" && $0.testament == .old }))
        XCTAssertTrue(bibleBooks.contains(where: { $0.name == "Matthew" && $0.testament == .new }))
        XCTAssertTrue(bibleBooks.contains(where: { $0.name == "Revelation" && $0.testament == .new }))
    }
    
    func testBookChapterCounts() {
        // Test some known chapter counts
        let genesis = bibleBooks.first { $0.name == "Genesis" }
        XCTAssertEqual(genesis?.chapters, 50)
        
        let psalms = bibleBooks.first { $0.name == "Psalms" }
        XCTAssertEqual(psalms?.chapters, 150)
        
        let john = bibleBooks.first { $0.name == "John" }
        XCTAssertEqual(john?.chapters, 21)
    }

    // MARK: - VerseReference Key Tests
    func testVerseReferenceKeyMatchesID() {
        let reference = VerseReference(book: "1 Corinthians", chapter: 13, verse: 4)
        XCTAssertEqual(reference.referenceKey, reference.id)
        XCTAssertEqual(reference.referenceKey, "1 Corinthians_13_4")
    }

    func testVerseReferenceKeyRoundTrip() {
        let reference = VerseReference(book: "Song of Solomon", chapter: 2, verse: 1)
        let key = reference.referenceKey
        let decoded = VerseReference.fromKey(key)

        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.book, reference.book)
        XCTAssertEqual(decoded?.chapter, reference.chapter)
        XCTAssertEqual(decoded?.verse, reference.verse)
    }
    
    // MARK: - BibleError Tests
    func testBibleErrorDescriptions() {
        XCTAssertEqual(BibleError.invalidURL.localizedDescription, "Invalid URL format")
        XCTAssertEqual(BibleError.networkError.localizedDescription, "Failed to fetch data from the server")
        XCTAssertEqual(BibleError.verseNotFound.localizedDescription, "Verse not found")
        XCTAssertEqual(BibleError.invalidBook.localizedDescription, "Invalid book reference")
        XCTAssertEqual(BibleError.storageError.localizedDescription, "Failed to access local storage")
        XCTAssertEqual(BibleError.decodingError.localizedDescription, "Failed to decode data")
    }
}
