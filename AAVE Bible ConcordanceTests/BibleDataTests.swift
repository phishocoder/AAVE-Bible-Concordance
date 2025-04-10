//
//  BibleDataTests.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//
//

import XCTest
@testable import AAVE_Bible_Concordance

final class BibleDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Add any setup code if needed
    }
    
    override func tearDown() {
        // Add any cleanup code if needed
        super.tearDown()
    }
    
    func testGenesisVerseCount() {
        // Test first chapter
        XCTAssertEqual(chapterVerseCount["Genesis"]?[1], 31)
        // Test middle chapter
        XCTAssertEqual(chapterVerseCount["Genesis"]?[25], 34)
        // Test last chapter
        XCTAssertEqual(chapterVerseCount["Genesis"]?[50], 26)
        // Test invalid chapter
        XCTAssertNil(chapterVerseCount["Genesis"]?[51])
    }
    
    func testJohnVerseCount() {
        // Test first chapter
        XCTAssertEqual(chapterVerseCount["John"]?[1], 51)
        // Test middle chapter
        XCTAssertEqual(chapterVerseCount["John"]?[11], 57)
        // Test last chapter
        XCTAssertEqual(chapterVerseCount["John"]?[21], 25)
        // Test invalid chapter
        XCTAssertNil(chapterVerseCount["John"]?[22])
    }
    
    func testVerseCountValidation() {
        // Valid cases
        XCTAssertTrue(validateVerseCount(book: "Genesis", chapter: 1, verse: 1))
        XCTAssertTrue(validateVerseCount(book: "Genesis", chapter: 1, verse: 31))
        XCTAssertTrue(validateVerseCount(book: "John", chapter: 3, verse: 16))
        
        // Invalid cases
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 1, verse: 32))
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 51, verse: 1))
        XCTAssertFalse(validateVerseCount(book: "InvalidBook", chapter: 1, verse: 1))
    }
    
    func testChapterCounts() {
        XCTAssertEqual(chapterVerseCount["Genesis"]?.count, 50)
        XCTAssertEqual(chapterVerseCount["Exodus"]?.count, 40)
        XCTAssertEqual(chapterVerseCount["John"]?.count, 21)
    }
    
    func testTotalVerseCountsPerBook() {
        // Test total verses in Genesis
        let genesisTotal = chapterVerseCount["Genesis"]?.values.reduce(0, +)
        XCTAssertEqual(genesisTotal, 1533) // Genesis has 1,533 verses
        
        // Test total verses in John
        let johnTotal = chapterVerseCount["John"]?.values.reduce(0, +)
        XCTAssertEqual(johnTotal, 879) // John has 879 verses
    }
    
    // New test cases being added here
    func testBookBoundaries() {
        // Test first verse of first chapter
        XCTAssertTrue(validateVerseCount(book: "Genesis", chapter: 1, verse: 1))
        XCTAssertTrue(validateVerseCount(book: "John", chapter: 1, verse: 1))
        
        // Test last verse of last chapter
        XCTAssertTrue(validateVerseCount(book: "Genesis", chapter: 50, verse: 26))
        XCTAssertTrue(validateVerseCount(book: "John", chapter: 21, verse: 25))
        
        // Test invalid boundaries
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 0, verse: 1))
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 1, verse: 0))
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 51, verse: 1))
    }

    func testChapterConsistency() {
        // Verify all books have consistent chapter counts with bibleBooks data
        for book in bibleBooks {
            let chaptersInMapping = chapterVerseCount[book.name]?.count ?? 0
            XCTAssertEqual(chaptersInMapping, book.chapters, "Chapter count mismatch for \(book.name)")
        }
    }

    func testVerseRangeValidation() {
        // Test edge cases
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: 1, verse: -1))
        XCTAssertFalse(validateVerseCount(book: "Genesis", chapter: -1, verse: 1))
        XCTAssertFalse(validateVerseCount(book: "", chapter: 1, verse: 1))
        
        // Test known valid verses
        XCTAssertTrue(validateVerseCount(book: "John", chapter: 3, verse: 16))
        XCTAssertTrue(validateVerseCount(book: "Genesis", chapter: 1, verse: 1))
    }
}
