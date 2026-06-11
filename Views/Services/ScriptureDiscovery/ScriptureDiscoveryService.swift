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

    init(
        dataSource: any ScriptureSearchDataSource,
        ranker: any ScriptureCandidateRanking,
        isNaturalLanguageRankingEnabled: Bool
    ) {
        self.dataSource = dataSource
        self.ranker = ranker
        self.isNaturalLanguageRankingEnabled = isNaturalLanguageRankingEnabled
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

        if !dataSource.isLoaded {
            try await dataSource.loadTranslations()
        }

        if SearchQueryParser.parseReference(from: trimmed) != nil || !isNaturalLanguageRankingEnabled {
            return try await dataSource.searchAAVEScripture(query: trimmed, limit: limit)
        }

        let lexicalPage = try await dataSource.searchAAVEScripture(
            query: trimmed,
            limit: Self.candidateLimit
        )
        guard ranker.isAvailable else {
            return limitedPage(from: lexicalPage.results, totalCount: lexicalPage.totalCount, limit: limit)
        }

        let candidates = try await candidateResults(query: trimmed, lexicalResults: lexicalPage.results)
        guard !candidates.isEmpty else {
            return limitedPage(from: lexicalPage.results, totalCount: lexicalPage.totalCount, limit: limit)
        }

        do {
            let proposedIndices = try await ranker.rankedCandidateIndices(
                query: trimmed,
                candidates: rankingCandidates(from: candidates),
                limit: limit
            )
            let validated = ScriptureCitationValidator.validatedOrder(
                proposedIndices: proposedIndices,
                candidateCount: candidates.count
            )
            guard !validated.isEmpty else {
                return limitedPage(from: lexicalPage.results, totalCount: lexicalPage.totalCount, limit: limit)
            }

            let completed = ScriptureCitationValidator.completeOrder(
                validatedIndices: validated,
                candidateCount: candidates.count
            )
            let results = completed.prefix(max(0, limit)).map { candidates[$0] }
            return SearchResultPage(
                results: results,
                totalCount: candidates.count,
                limit: max(0, limit)
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return limitedPage(from: lexicalPage.results, totalCount: lexicalPage.totalCount, limit: limit)
        }
    }

    private func candidateResults(
        query: String,
        lexicalResults: [SearchResult]
    ) async throws -> [SearchResult] {
        var candidates = lexicalResults
        var seen = Set(lexicalResults.map(\.id))

        for term in ScriptureQueryExpander.searchTerms(for: query) {
            guard candidates.count < Self.candidateLimit else { break }
            let page = try await dataSource.searchAAVEScripture(
                query: term,
                limit: Self.candidateLimit
            )
            for result in page.results where result.kind == .verse && seen.insert(result.id).inserted {
                candidates.append(result)
                if candidates.count == Self.candidateLimit { break }
            }
        }

        return Array(candidates.prefix(Self.candidateLimit))
    }

    private func rankingCandidates(from results: [SearchResult]) -> [ScriptureRankingCandidate] {
        results.enumerated().map { index, result in
            ScriptureRankingCandidate(
                index: index,
                reference: result.displayTitle,
                excerpt: String(result.text.prefix(180))
            )
        }
    }

    private func limitedPage(
        from results: [SearchResult],
        totalCount: Int,
        limit: Int
    ) -> SearchResultPage {
        let safeLimit = max(0, limit)
        return SearchResultPage(
            results: Array(results.prefix(safeLimit)),
            totalCount: totalCount,
            limit: safeLimit
        )
    }
}
