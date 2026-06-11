import Foundation

@MainActor
struct DeterministicStudyGuideContentGenerator: StudyGuideContentGenerator {
    let isAvailable = true

    func generateContent(for input: StudyGuideContentInput) async throws -> StudyGuideGeneratedContent {
        StudyGuideGeneratedContent(
            summary: "This passage presents a central message to consider carefully and apply faithfully in everyday life.",
            reflectionQuestions: [
                "What stands out to you in this passage?",
                "How could you put its message into practice today?"
            ],
            source: .deterministicFallback
        )
    }
}
