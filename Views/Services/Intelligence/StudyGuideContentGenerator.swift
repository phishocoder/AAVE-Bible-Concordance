import Foundation

struct StudyGuideContentInput: Equatable, Sendable {
    let passageText: String
    let commentary: String?
}

struct StudyGuideGeneratedContent: Equatable, Sendable {
    let summary: String
    let reflectionQuestions: [String]
    let source: StudyGuide.Source
}

enum StudyGuideContentGenerationError: Error, Equatable {
    case unavailable
    case timedOut
    case invalidStructure
    case unsafeOutput
}

@MainActor
protocol StudyGuideContentGenerator {
    var isAvailable: Bool { get }

    func generateContent(for input: StudyGuideContentInput) async throws -> StudyGuideGeneratedContent
}

enum StudyGuideContentValidator {
    static func validated(
        _ content: StudyGuideGeneratedContent,
        for input: StudyGuideContentInput
    ) throws -> StudyGuideGeneratedContent {
        let summary = content.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let questions = content.reflectionQuestions.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard !summary.isEmpty,
              summary.count <= 500,
              questions.count == 2,
              questions.allSatisfy({ !$0.isEmpty && $0.hasSuffix("?") }),
              Set(questions.map { $0.lowercased() }).count == 2 else {
            throw StudyGuideContentGenerationError.invalidStructure
        }

        let allGeneratedText = ([summary] + questions).joined(separator: " ")
        guard !containsReference(in: allGeneratedText),
              !containsBundledPassageQuote(in: allGeneratedText, passageText: input.passageText) else {
            throw StudyGuideContentGenerationError.unsafeOutput
        }

        return StudyGuideGeneratedContent(
            summary: summary,
            reflectionQuestions: questions,
            source: content.source
        )
    }

    private static func containsReference(in text: String) -> Bool {
        let pattern = #"\b(?:[1-3]\s+)?[A-Za-z]+(?:\s+[A-Za-z]+){0,2}\s+\d{1,3}:\d{1,3}\b"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func containsBundledPassageQuote(in output: String, passageText: String) -> Bool {
        let passageWords = words(in: passageText)
        let outputWords = words(in: output)
        guard passageWords.count >= 8, outputWords.count >= 8 else {
            let normalizedPassage = passageWords.joined(separator: " ")
            let normalizedOutput = outputWords.joined(separator: " ")
            return normalizedPassage.count >= 20 && normalizedOutput.contains(normalizedPassage)
        }

        let outputText = outputWords.joined(separator: " ")
        for start in 0...(passageWords.count - 8) {
            let phrase = passageWords[start..<(start + 8)].joined(separator: " ")
            if outputText.contains(phrase) {
                return true
            }
        }
        return false
    }

    private static func words(in text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" })
            .map(String.init)
    }
}
