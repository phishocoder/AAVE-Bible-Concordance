import Foundation

@MainActor
protocol ScriptureSearchDataSource: AnyObject {
    var isLoaded: Bool { get }
    func loadTranslations() async throws
    func searchAAVEScripture(query: String, limit: Int) async throws -> SearchResultPage
}

extension TranslationService: ScriptureSearchDataSource {}

@MainActor
protocol ScriptureDiscovering {
    func search(query: String, limit: Int) async throws -> SearchResultPage
}

@MainActor
final class DefaultScriptureDiscoveryService: ScriptureDiscovering {
    static let shared = DefaultScriptureDiscoveryService()
    private static let candidateLimit = 100

    private let dataSource: any ScriptureSearchDataSource
    private let ranker: any ScriptureCandidateRanking
    private let isNaturalLanguageRankingEnabled: Bool
    private let rankingTimeoutNanoseconds: UInt64

    init(
        dataSource: any ScriptureSearchDataSource,
        ranker: any ScriptureCandidateRanking,
        isNaturalLanguageRankingEnabled: Bool,
        rankingTimeoutNanoseconds: UInt64 = 3_000_000_000
    ) {
        self.dataSource = dataSource
        self.ranker = ranker
        self.isNaturalLanguageRankingEnabled = isNaturalLanguageRankingEnabled
        self.rankingTimeoutNanoseconds = rankingTimeoutNanoseconds
    }

    convenience init() {
        self.init(
            dataSource: TranslationService.shared,
            ranker: FoundationModelScriptureRanker(),
            isNaturalLanguageRankingEnabled: InternalFeatureFlags.naturalLanguageScriptureSearchEnabled
        )
    }

    func search(query: String, limit: Int) async throws -> SearchResultPage {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty(limit: limit) }
        if !dataSource.isLoaded { try await dataSource.loadTranslations() }

        if SearchQueryParser.parseReference(from: trimmed) != nil || !isNaturalLanguageRankingEnabled {
            return try await dataSource.searchAAVEScripture(query: trimmed, limit: limit)
        }

        let lexicalPage = try await dataSource.searchAAVEScripture(query: trimmed, limit: Self.candidateLimit)
        guard ranker.isAvailable else { return limitedPage(from: lexicalPage, limit: limit, source: .lexical) }

        let candidates: [SearchResult]
        do {
            candidates = try await candidateResults(query: trimmed, lexicalResults: lexicalPage.results)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return limitedPage(from: lexicalPage, limit: limit, source: .aiFallback)
        }
        guard !candidates.isEmpty else { return limitedPage(from: lexicalPage, limit: limit, source: .lexical) }

        do {
            let proposed = try await rankedCandidateIndices(
                query: trimmed,
                candidates: rankingCandidates(from: candidates),
                limit: max(0, limit)
            )
            let validated = ScriptureCitationValidator.validatedOrder(
                proposedIndices: proposed,
                candidateCount: candidates.count
            )
            guard !validated.isEmpty else {
                return limitedPage(from: lexicalPage, limit: limit, source: .aiFallback)
            }
            let order = ScriptureCitationValidator.completeOrder(
                validatedIndices: validated,
                candidateCount: candidates.count
            )
            let safeLimit = max(0, limit)
            return SearchResultPage(
                results: order.prefix(safeLimit).map { candidates[$0] },
                totalCount: candidates.count,
                limit: safeLimit,
                rankingSource: .aiAssisted
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return limitedPage(from: lexicalPage, limit: limit, source: .aiFallback)
        }
    }

    private func rankedCandidateIndices(
        query: String,
        candidates: [ScriptureRankingCandidate],
        limit: Int
    ) async throws -> [Int] {
        try await withThrowingTaskGroup(of: [Int].self) { group in
            group.addTask {
                try await self.ranker.rankedCandidateIndices(query: query, candidates: candidates, limit: limit)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: self.rankingTimeoutNanoseconds)
                throw ScriptureRankingError.timedOut
            }
            guard let result = try await group.next() else { throw ScriptureRankingError.unavailable }
            group.cancelAll()
            return result
        }
    }

    private func candidateResults(query: String, lexicalResults: [SearchResult]) async throws -> [SearchResult] {
        var candidates = lexicalResults
        var seen = Set(lexicalResults.map(\.id))
        for term in ScriptureQueryExpander.searchTerms(for: query) {
            guard candidates.count < Self.candidateLimit else { break }
            let page = try await dataSource.searchAAVEScripture(query: term, limit: Self.candidateLimit)
            for result in page.results where result.kind == .verse && seen.insert(result.id).inserted {
                candidates.append(result)
                if candidates.count == Self.candidateLimit { break }
            }
        }
        return Array(candidates.prefix(Self.candidateLimit))
    }

    private func rankingCandidates(from results: [SearchResult]) -> [ScriptureRankingCandidate] {
        results.enumerated().map {
            ScriptureRankingCandidate(index: $0.offset, reference: $0.element.displayTitle, excerpt: String($0.element.text.prefix(180)))
        }
    }

    private func limitedPage(from page: SearchResultPage, limit: Int, source: SearchRankingSource) -> SearchResultPage {
        let safeLimit = max(0, limit)
        return SearchResultPage(
            results: Array(page.results.prefix(safeLimit)),
            totalCount: page.totalCount,
            limit: safeLimit,
            rankingSource: source
        )
    }
}
