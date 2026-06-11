import Foundation

@MainActor
final class DefaultIntelligenceService: IntelligenceService {
    static let shared = DefaultIntelligenceService()

    var availability: IntelligenceAvailability {
        FoundationModelsAvailabilityProvider.availability
    }

    private let translationService: TranslationService
    private let contentGenerator: any StudyGuideContentGenerator
    private let fallbackGenerator: any StudyGuideContentGenerator
    private let isFoundationModelsGenerationEnabled: Bool
    private let generationTimeoutNanoseconds: UInt64

    init(
        translationService: TranslationService,
        contentGenerator: any StudyGuideContentGenerator,
        isFoundationModelsGenerationEnabled: Bool,
        generationTimeoutNanoseconds: UInt64 = 3_000_000_000
    ) {
        self.translationService = translationService
        self.contentGenerator = contentGenerator
        self.fallbackGenerator = DeterministicStudyGuideContentGenerator()
        self.isFoundationModelsGenerationEnabled = isFoundationModelsGenerationEnabled
        self.generationTimeoutNanoseconds = generationTimeoutNanoseconds
    }

    convenience init(translationService: TranslationService) {
        self.init(
            translationService: translationService,
            contentGenerator: FoundationModelStudyGuideContentGenerator(),
            isFoundationModelsGenerationEnabled: InternalFeatureFlags.studyGuideFoundationModelsEnabled
        )
    }

    convenience init() {
        self.init(translationService: .shared)
    }

    func studyGuide(for reference: VerseReference) async throws -> StudyGuide {
        if !translationService.isLoaded {
            try await translationService.loadTranslations()
        }

        let passageText = try await translationService.getVerseTranslation(
            for: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            translation: "AAVE"
        )
        let commentary = translationService.getVerseCommentary(
            for: reference.book,
            chapter: reference.chapter,
            verse: reference.verse
        )
        let relatedReferences = try await relatedReferences(
            passageText: passageText,
            excluding: reference
        )
        let input = StudyGuideContentInput(
            passageText: passageText,
            commentary: commentary
        )
        let generatedContent = try await generatedContent(for: input)

        return StudyGuide(
            passageText: passageText,
            commentary: commentary,
            summary: generatedContent.summary,
            reflectionQuestions: generatedContent.reflectionQuestions,
            sourceReferences: [reference],
            relatedReferences: relatedReferences,
            source: generatedContent.source
        )
    }

    private func generatedContent(
        for input: StudyGuideContentInput
    ) async throws -> StudyGuideGeneratedContent {
        guard isFoundationModelsGenerationEnabled, contentGenerator.isAvailable else {
            return try await fallbackGenerator.generateContent(for: input)
        }

        do {
            let content = try await contentWithTimeout(for: input)
            return try StudyGuideContentValidator.validated(content, for: input)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return try await fallbackGenerator.generateContent(for: input)
        }
    }

    private func contentWithTimeout(
        for input: StudyGuideContentInput
    ) async throws -> StudyGuideGeneratedContent {
        try await withThrowingTaskGroup(of: StudyGuideGeneratedContent.self) { group in
            group.addTask {
                try await self.contentGenerator.generateContent(for: input)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: self.generationTimeoutNanoseconds)
                throw StudyGuideContentGenerationError.timedOut
            }

            guard let result = try await group.next() else {
                throw StudyGuideContentGenerationError.unavailable
            }
            group.cancelAll()
            return result
        }
    }

    private func relatedReferences(
        passageText: String,
        excluding sourceReference: VerseReference
    ) async throws -> [VerseReference] {
        guard let searchTerm = Self.searchTerm(from: passageText) else { return [] }
        let results = try await translationService.searchVerses(query: searchTerm)

        var seen = Set<String>()
        return results.compactMap(\.reference).filter { reference in
            guard reference.id != sourceReference.id else { return false }
            return seen.insert(reference.id).inserted
        }
        .prefix(5)
        .map { $0 }
    }

    private static func searchTerm(from passageText: String) -> String? {
        let stopWords: Set<String> = [
            "about", "after", "ain't", "also", "anybody", "because", "been", "before",
            "being", "could", "from", "gave", "getting", "have", "into", "just", "mad",
            "more", "only", "really", "showing", "that", "their", "them", "then", "they",
            "this", "when", "where", "which", "while", "with", "world", "would"
        ]

        return passageText
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" })
            .map(String.init)
            .first { word in
                word.count >= 4 && !stopWords.contains(word)
            }
    }
}
