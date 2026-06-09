import Foundation

@MainActor
final class DefaultIntelligenceService: IntelligenceService {
    static let shared = DefaultIntelligenceService()

    var availability: IntelligenceAvailability {
        FoundationModelsAvailabilityProvider.availability
    }

    private let translationService: TranslationService

    init(translationService: TranslationService) {
        self.translationService = translationService
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

        return StudyGuide(
            passageText: passageText,
            commentary: commentary,
            summary: nil,
            reflectionQuestions: [],
            sourceReferences: [reference],
            relatedReferences: relatedReferences,
            source: .deterministicFallback
        )
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
