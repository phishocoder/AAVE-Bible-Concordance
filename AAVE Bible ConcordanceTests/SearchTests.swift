import XCTest
@testable import AAVE_Bible_Concordance

final class SearchTests: XCTestCase {
    func testDirectReferenceParsing() {
        XCTAssertEqual(
            SearchQueryParser.parseReference(from: "John 3:16"),
            ParsedReference(book: "John", chapter: 3, verse: 16)
        )
        XCTAssertEqual(
            SearchQueryParser.parseReference(from: "Romans 8"),
            ParsedReference(book: "Romans", chapter: 8, verse: nil)
        )
        XCTAssertEqual(
            SearchQueryParser.parseReference(from: "Psalm 23"),
            ParsedReference(book: "Psalms", chapter: 23, verse: nil)
        )
    }

    func testExactPhraseRanksAbovePartialMatch() {
        let page = SearchResultRanker.rankedPage(
            query: "peace be",
            candidates: [
                result(book: "John", verse: 2, text: "Peacemaker blessings be with y'all."),
                result(book: "John", verse: 1, text: "Peace be with y'all.")
            ],
            limit: 50
        )

        XCTAssertEqual(page.results.map(\.verse), [1, 2])
    }

    func testWholeWordRanksAbovePartialToken() {
        let page = SearchResultRanker.rankedPage(
            query: "love",
            candidates: [
                result(book: "John", verse: 2, text: "Beloved, keep going."),
                result(book: "John", verse: 1, text: "Love one another.")
            ],
            limit: 50
        )

        XCTAssertEqual(page.results.map(\.verse), [1, 2])
    }

    func testAllTokenMatchRanksAfterExactPhrase() {
        let page = SearchResultRanker.rankedPage(
            query: "faith works",
            candidates: [
                result(book: "James", verse: 2, text: "Faith grows when love works through us."),
                result(book: "James", verse: 1, text: "Faith works through love.")
            ],
            limit: 50
        )

        XCTAssertEqual(page.results.map(\.verse), [1, 2])
        XCTAssertEqual(
            SearchResultRanker.rank(for: page.results[1], query: "faith works"),
            .allTokens
        )
    }

    func testEqualRanksUseCanonicalBibleOrder() {
        let page = SearchResultRanker.rankedPage(
            query: "wisdom",
            candidates: [
                result(book: "John", chapter: 2, verse: 1, text: "Wisdom speaks."),
                result(book: "Genesis", chapter: 2, verse: 1, text: "Wisdom speaks."),
                result(book: "Genesis", chapter: 1, verse: 2, text: "Wisdom speaks."),
                result(book: "Genesis", chapter: 1, verse: 1, text: "Wisdom speaks.")
            ],
            limit: 50
        )

        XCTAssertEqual(
            page.results.map(\.displayTitle),
            ["Genesis 1:1", "Genesis 1:2", "Genesis 2:1", "John 2:1"]
        )
    }

    func testResultLimitPreservesTotalCount() {
        let candidates = (1...60).map {
            result(book: "Psalms", verse: $0, text: "Peace for everybody.")
        }
        let page = SearchResultRanker.rankedPage(
            query: "peace",
            candidates: candidates,
            limit: 50
        )

        XCTAssertEqual(page.results.count, 50)
        XCTAssertEqual(page.totalCount, 60)
        XCTAssertTrue(page.isLimited)
    }

    func testEmptyQueryReturnsNoRankedResults() {
        let page = SearchResultRanker.rankedPage(
            query: "   ",
            candidates: [result(book: "John", verse: 1, text: "Peace.")],
            limit: 50
        )

        XCTAssertTrue(page.results.isEmpty)
        XCTAssertEqual(page.totalCount, 0)
    }

    @MainActor
    func testAAVESearchReturnsEmptyPageForEmptyQuery() async throws {
        let page = try await TranslationService.shared.searchAAVEScripture(
            query: " ",
            limit: 50
        )

        XCTAssertTrue(page.results.isEmpty)
        XCTAssertEqual(page.totalCount, 0)
    }

    private func result(
        book: String,
        chapter: Int = 1,
        verse: Int,
        text: String
    ) -> SearchResult {
        SearchResult(
            book: book,
            chapter: chapter,
            verse: verse,
            aaveText: text,
            traditionalText: ""
        )
    }
}
