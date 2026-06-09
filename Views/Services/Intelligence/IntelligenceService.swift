import Foundation

@MainActor
protocol IntelligenceService {
    var availability: IntelligenceAvailability { get }

    func studyGuide(for reference: VerseReference) async throws -> StudyGuide
}
