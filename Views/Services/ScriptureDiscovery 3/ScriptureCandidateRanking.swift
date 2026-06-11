import Foundation

struct ScriptureRankingCandidate: Sendable {
    let index: Int
    let reference: String
    let excerpt: String
}

@MainActor
protocol ScriptureCandidateRanking {
    var isAvailable: Bool { get }

    func rankedCandidateIndices(
        query: String,
        candidates: [ScriptureRankingCandidate],
        limit: Int
    ) async throws -> [Int]
}

struct ScriptureCitationValidator {
    static func validatedOrder(proposedIndices: [Int], candidateCount: Int) -> [Int] {
        guard candidateCount > 0 else { return [] }
        var seen = Set<Int>()
        return proposedIndices.filter {
            (0..<candidateCount).contains($0) && seen.insert($0).inserted
        }
    }

    static func completeOrder(validatedIndices: [Int], candidateCount: Int) -> [Int] {
        let selected = Set(validatedIndices)
        return validatedIndices + (0..<candidateCount).filter { !selected.contains($0) }
    }
}
