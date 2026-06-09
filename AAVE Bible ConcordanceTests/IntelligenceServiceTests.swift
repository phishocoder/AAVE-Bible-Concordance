import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class IntelligenceServiceTests: XCTestCase {
    private let service = DefaultIntelligenceService.shared

    override func setUp() async throws {
        try await TranslationService.shared.loadTranslations()
    }

    func testFallbackPreservesBundledScriptureAndSourceReference() async throws {
        let reference = VerseReference(book: "John", chapter: 3, verse: 16)
        let expectedText = try await TranslationService.shared.getVerseTranslation(
            for: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            translation: "AAVE"
        )

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.passageText, expectedText)
        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(guide.sourceReferences.map(\.id), [reference.id])
        XCTAssertNil(guide.summary)
        XCTAssertTrue(guide.reflectionQuestions.isEmpty)
    }

    func testFallbackUsesBundledCommentaryAndAppOwnedRelatedReferences() async throws {
        let reference = VerseReference(book: "John", chapter: 3, verse: 16)

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(
            guide.commentary,
            TranslationService.shared.getVerseCommentary(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse
            )
        )
        XCTAssertFalse(guide.relatedReferences.contains { $0.id == reference.id })
        XCTAssertEqual(
            Set(guide.relatedReferences.map(\.id)).count,
            guide.relatedReferences.count
        )
    }

    func testFallbackFailsWhenBundledPassageDoesNotExist() async {
        let missing = VerseReference(book: "John", chapter: 3, verse: 999)

        do {
            _ = try await service.studyGuide(for: missing)
            XCTFail("Expected missing bundled Scripture to fail.")
        } catch BibleError.verseNotFound {
            // Expected.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
