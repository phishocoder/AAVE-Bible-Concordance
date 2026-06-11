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
    static func validatedOrder(
        proposedIndices: [Int],
        candidateCount: Int
    ) -> [Int] {
        guard candidateCount > 0 else { return [] }

        var seen = Set<Int>()
        var validated: [Int] = []

        for index in proposedIndices where (0..<candidateCount).contains(index) {
            if seen.insert(index).inserted {
                validated.append(index)
            }
        }

        return validated
    }

    static func completeOrder(
        validatedIndices: [Int],
        candidateCount: Int
    ) -> [Int] {
        var order = validatedIndices
        let selected = Set(validatedIndices)
        order.append(contentsOf: (0..<candidateCount).filter { !selected.contains($0) })
        return order
    }
}
