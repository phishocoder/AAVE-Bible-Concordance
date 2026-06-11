import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class ScriptureDiscoveryServiceTests: XCTestCase {
    func testDirectReferenceBypassesCandidateRanker() async throws {
        let directResult = result(book: "John", chapter: 3, verse: 16, text: "Bundled text")
        let dataSource = StubSearchDataSource(pages: [
            "John 3:16": page([directResult])
        ])
        let ranker = StubCandidateRanker(proposedIndices: [0])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(query: "John 3:16", limit: 25)

        XCTAssertEqual(resultPage.results.map(\.id), [directResult.id])
        XCTAssertEqual(ranker.callCount, 0)
        XCTAssertEqual(dataSource.queries, ["John 3:16"])
    }

    func testInvalidAndDuplicateIndicesAreRejectedAndOmissionsKeepLexicalOrder() async throws {
        let candidates = [
            result(book: "Psalms", chapter: 1, verse: 1, text: "Peace one"),
            result(book: "Psalms", chapter: 1, verse: 2, text: "Peace two"),
            result(book: "Psalms", chapter: 1, verse: 3, text: "Peace three")
        ]
        let dataSource = StubSearchDataSource(pages: ["peace": page(candidates)])
        let ranker = StubCandidateRanker(proposedIndices: [2, 99, -1, 2, 0])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(query: "peace", limit: 3)

        XCTAssertEqual(resultPage.results.map(\.verse), [3, 1, 2])
        XCTAssertEqual(Set(resultPage.results.map(\.id)).count, 3)
    }

    func testModelFailureReturnsOriginalLexicalResults() async throws {
        let lexical = [
            result(book: "John", chapter: 1, verse: 1, text: "Love one another"),
            result(book: "John", chapter: 1, verse: 2, text: "Love is patient")
        ]
        let dataSource = StubSearchDataSource(pages: ["love": page(lexical)])
        let ranker = StubCandidateRanker(proposedIndices: [], shouldThrow: true)
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(query: "love", limit: 25)

        XCTAssertEqual(resultPage.results.map(\.id), lexical.map(\.id))
    }

    func testEmptyValidatedRankingReturnsOriginalLexicalResults() async throws {
        let lexical = [result(book: "James", chapter: 1, verse: 5, text: "Ask for wisdom")]
        let dataSource = StubSearchDataSource(pages: ["wisdom": page(lexical)])
        let ranker = StubCandidateRanker(proposedIndices: [88])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(query: "wisdom", limit: 25)

        XCTAssertEqual(resultPage.results.map(\.id), lexical.map(\.id))
    }

    func testExpansionCanSupplyCandidatesWithoutAllowingNewReferences() async throws {
        let expanded = result(book: "Philippians", chapter: 4, verse: 6, text: "Do not be anxious")
        let dataSource = StubSearchDataSource(pages: [
            "verses for when I feel anxious": .empty(limit: 100),
            "anxious": page([expanded])
        ])
        let ranker = StubCandidateRanker(proposedIndices: [0])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(
            query: "verses for when I feel anxious",
            limit: 25
        )

        XCTAssertEqual(resultPage.results.map(\.id), [expanded.id])
        XCTAssertTrue(dataSource.queries.contains("anxious"))
    }

    func testNaturalLanguageFixtureQueriesProduceBoundedExpansionTerms() {
        let queries = [
            "verses for when I feel anxious",
            "scriptures for fear and worry",
            "what does Jesus say about forgiveness?",
            "where does Jesus teach us to love our enemies?",
            "scriptures about money and wisdom",
            "where does Paul talk about love?",
            "verses for when I feel alone",
            "help me find hope after loss",
            "what does the Bible say about anger?",
            "verses about being patient",
            "scriptures for making a hard decision",
            "what does Jesus say about judging people?",
            "verses about trusting God",
            "scriptures about helping poor people",
            "where does Paul discuss spiritual gifts?",
            "verses about marriage and commitment",
            "what does Proverbs say about controlling your words?",
            "scriptures for getting through temptation",
            "verses about justice",
            "where does Peter talk about suffering?",
            "scriptures about raising children wisely",
            "what does James say about faith and works?",
            "verses for being thankful",
            "scriptures about pride and humility",
            "where does the Bible talk about welcoming strangers?"
        ]

        XCTAssertEqual(queries.count, 25)
        for query in queries {
            let terms = ScriptureQueryExpander.searchTerms(for: query)
            XCTAssertFalse(terms.isEmpty, "Expected expansion terms for: \(query)")
            XCTAssertLessThanOrEqual(terms.count, 10)
            XCTAssertEqual(Set(terms).count, terms.count)
        }
    }

    func testCitationValidatorIsDeterministic() {
        let validated = ScriptureCitationValidator.validatedOrder(
            proposedIndices: [3, 1, 3, 20, -2],
            candidateCount: 5
        )
        let completed = ScriptureCitationValidator.completeOrder(
            validatedIndices: validated,
            candidateCount: 5
        )

        XCTAssertEqual(validated, [3, 1])
        XCTAssertEqual(completed, [3, 1, 0, 2, 4])
    }

    private func result(
        book: String,
        chapter: Int,
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

    private func page(_ results: [SearchResult]) -> SearchResultPage {
        SearchResultPage(results: results, totalCount: results.count, limit: 100)
    }
}

@MainActor
private final class StubSearchDataSource: ScriptureSearchDataSource {
    var isLoaded = true
    private(set) var queries: [String] = []

    private let pages: [String: SearchResultPage]

    init(pages: [String: SearchResultPage]) {
        self.pages = pages
    }

    func loadTranslations() async throws {
        isLoaded = true
    }

    func searchAAVEScripture(query: String, limit: Int) async throws -> SearchResultPage {
        queries.append(query)
        let stored = pages[query] ?? .empty(limit: limit)
        return SearchResultPage(
            results: Array(stored.results.prefix(max(0, limit))),
            totalCount: stored.totalCount,
            limit: max(0, limit)
        )
    }
}

@MainActor
private final class StubCandidateRanker: ScriptureCandidateRanking {
    let isAvailable = true
    private(set) var callCount = 0

    private let proposedIndices: [Int]
    private let shouldThrow: Bool

    init(proposedIndices: [Int], shouldThrow: Bool = false) {
        self.proposedIndices = proposedIndices
        self.shouldThrow = shouldThrow
    }

    func rankedCandidateIndices(
        query: String,
        candidates: [ScriptureRankingCandidate],
        limit: Int
    ) async throws -> [Int] {
        callCount += 1
        if shouldThrow {
            throw ScriptureRankingError.unavailable
        }
        return proposedIndices
    }
}
