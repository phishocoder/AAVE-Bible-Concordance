import Foundation

struct StudyGuide: Equatable, Sendable {
    enum Source: String, Equatable, Sendable {
        case deterministicFallback
        case appleFoundationModels
    }

    let passageText: String
    let commentary: String?
    let summary: String?
    let reflectionQuestions: [String]
    let sourceReferences: [VerseReference]
    let relatedReferences: [VerseReference]
    let source: Source
}
