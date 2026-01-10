//
//  BookNameNormalizerTests.swift
//  AAVE Bible ConcordanceTests
//

import XCTest
@testable import AAVE_Bible_Concordance

final class BookNameNormalizerTests: XCTestCase {
    func testNumericPrefixNormalization() {
        XCTAssertEqual(BookNameNormalizer.canonicalBookName("1 cor"), "1 Corinthians")
        XCTAssertEqual(BookNameNormalizer.canonicalBookName("i corinthians"), "1 Corinthians")
    }

    func testSongOfSongsAlias() {
        XCTAssertEqual(BookNameNormalizer.canonicalBookName("song of songs"), "Song of Solomon")
        XCTAssertEqual(BookNameNormalizer.canonicalBookName("song of solomon"), "Song of Solomon")
    }
}
