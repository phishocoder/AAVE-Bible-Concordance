import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class ScriptureDiscoveryServiceTests: XCTestCase {
    func testDirectReferencesBypassCandidateRanker() async throws {
        let john = result(book: "John", chapter: 3, verse: 16, text: "Bundled text")
        let romans = result(book: "Romans", chapter: 8, verse: 1, text: "Bundled text")
        let psalms = result(book: "Psalms", chapter: 23, verse: 1, text: "Bundled text")
        let dataSource = StubSearchDataSource(pages: [
            "John 3:16": page([john]),
            "Romans 8": page([romans]),
            "Psalm 23": page([psalms])
        ])
        let ranker = StubCandidateRanker(proposedIndices: [0])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        for query in ["John 3:16", "Romans 8", "Psalm 23"] {
            let resultPage = try await service.search(query: query, limit: 50)
            XCTAssertEqual(resultPage.rankingSource, .lexical)
        }
        XCTAssertEqual(ranker.callCount, 0)
        XCTAssertEqual(dataSource.queries, ["John 3:16", "Romans 8", "Psalm 23"])
    }

    func testInvalidAndDuplicateIndicesAreRejectedAndOmissionsKeepCandidateOrder() async throws {
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
        XCTAssertEqual(resultPage.rankingSource, .aiAssisted)
    }

    func testUnavailableModelReturnsOriginalLexicalResults() async throws {
        let lexical = [
            result(book: "John", chapter: 1, verse: 1, text: "Love one another"),
            result(book: "John", chapter: 1, verse: 2, text: "Love is patient")
        ]
        let dataSource = StubSearchDataSource(pages: ["love": page(lexical)])
        let ranker = StubCandidateRanker(isAvailable: false, proposedIndices: [])
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let resultPage = try await service.search(query: "love", limit: 25)

        XCTAssertEqual(resultPage.results.map(\.id), lexical.map(\.id))
        XCTAssertEqual(resultPage.rankingSource, .lexical)
        XCTAssertEqual(ranker.callCount, 0)
    }

    func testModelFailureReturnsDeterministicLexicalFallback() async throws {
        let lexical = [
            result(book: "John", chapter: 1, verse: 1, text: "Love one another"),
            result(book: "John", chapter: 1, verse: 2, text: "Love is patient")
        ]
        let dataSource = StubSearchDataSource(pages: ["love": page(lexical)])
        let ranker = StubCandidateRanker(proposedIndices: [], error: .unavailable)
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true
        )

        let firstPage = try await service.search(query: "love", limit: 50)
        let secondPage = try await service.search(query: "love", limit: 50)

        XCTAssertEqual(firstPage.results.map(\.id), lexical.map(\.id))
        XCTAssertEqual(secondPage.results.map(\.id), lexical.map(\.id))
        XCTAssertEqual(firstPage.rankingSource, .aiFallback)
        XCTAssertEqual(secondPage.rankingSource, .aiFallback)
    }

    func testTimeoutReturnsDeterministicLexicalFallback() async throws {
        let lexical = [
            result(book: "Psalms", chapter: 1, verse: 1, text: "Hope one"),
            result(book: "Psalms", chapter: 1, verse: 2, text: "Hope two")
        ]
        let dataSource = StubSearchDataSource(pages: ["hope": page(lexical)])
        let ranker = StubCandidateRanker(
            proposedIndices: [1, 0],
            delayNanoseconds: 50_000_000
        )
        let service = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: ranker,
            isNaturalLanguageRankingEnabled: true,
            rankingTimeoutNanoseconds: 1_000_000
        )

        let resultPage = try await service.search(query: "hope", limit: 50)

        XCTAssertEqual(resultPage.results.map(\.id), lexical.map(\.id))
        XCTAssertEqual(resultPage.rankingSource, .aiFallback)
    }

    func testOutsideCandidateSetOutputReturnsLexicalFallback() async throws {
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
        XCTAssertEqual(resultPage.rankingSource, .aiFallback)
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
        XCTAssertEqual(resultPage.rankingSource, .aiAssisted)
    }

    func testLexicalAndAIRankingUseTheSameRequestedResultLimit() async throws {
        let candidates = (1...60).map {
            result(book: "Psalms", chapter: 1, verse: $0, text: "Hope \($0)")
        }
        let dataSource = StubSearchDataSource(pages: ["hope": page(candidates)])
        let aiService = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: StubCandidateRanker(proposedIndices: Array(0..<60)),
            isNaturalLanguageRankingEnabled: true
        )
        let lexicalService = DefaultScriptureDiscoveryService(
            dataSource: dataSource,
            ranker: StubCandidateRanker(isAvailable: false, proposedIndices: []),
            isNaturalLanguageRankingEnabled: true
        )

        let aiPage = try await aiService.search(query: "hope", limit: 50)
        let lexicalPage = try await lexicalService.search(query: "hope", limit: 50)

        XCTAssertEqual(aiPage.results.count, 50)
        XCTAssertEqual(aiPage.limit, 50)
        XCTAssertEqual(lexicalPage.results.count, 50)
        XCTAssertEqual(lexicalPage.limit, 50)
        XCTAssertEqual(aiPage.rankingSource, .aiAssisted)
        XCTAssertEqual(lexicalPage.rankingSource, .lexical)
    }

    func testProductionDefaultDisablesAISearchRanking() {
        XCTAssertFalse(
            InternalFeatureFlags.naturalLanguageScriptureSearchEnabled(isDebugBuild: false)
        )
    }

    func testDebugFlagMarksAISearchRankingAsExperimental() {
        XCTAssertTrue(
            InternalFeatureFlags.naturalLanguageScriptureSearchEnabled(isDebugBuild: true)
        )
        XCTAssertEqual(
            SearchRankingSource.aiAssisted.experimentalDisplayName,
            "Experimental AI-assisted ranking"
        )
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
    let isAvailable: Bool
    private(set) var callCount = 0

    private let proposedIndices: [Int]
    private let error: ScriptureRankingError?
    private let delayNanoseconds: UInt64

    init(
        isAvailable: Bool = true,
        proposedIndices: [Int],
        error: ScriptureRankingError? = nil,
        delayNanoseconds: UInt64 = 0
    ) {
        self.isAvailable = isAvailable
        self.proposedIndices = proposedIndices
        self.error = error
        self.delayNanoseconds = delayNanoseconds
    }

    func rankedCandidateIndices(
        query: String,
        candidates: [ScriptureRankingCandidate],
        limit: Int
    ) async throws -> [Int] {
        callCount += 1
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        if let error {
            throw error
        }
        return proposedIndices
    }
}
