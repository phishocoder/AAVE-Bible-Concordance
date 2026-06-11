import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class IntelligenceServiceTests: XCTestCase {
    private let reference = VerseReference(book: "John", chapter: 3, verse: 16)

    override func setUp() async throws {
        try await TranslationService.shared.loadTranslations()
    }

    func testModelUnavailableUsesDeterministicFallback() async throws {
        let service = makeService(generator: StubStudyGuideContentGenerator(isAvailable: false))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertNotNil(guide.summary)
        XCTAssertEqual(guide.reflectionQuestions.count, 2)
    }

    func testModelFailureUsesDeterministicFallback() async throws {
        let service = makeService(
            generator: StubStudyGuideContentGenerator(behavior: .failure)
        )

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(guide.reflectionQuestions.count, 2)
    }

    func testTimeoutUsesDeterministicFallback() async throws {
        let generator = StubStudyGuideContentGenerator(
            behavior: .delayed(
                nanoseconds: 1_000_000_000,
                content: validGeneratedContent()
            )
        )
        let service = makeService(generator: generator, timeoutNanoseconds: 1_000_000)

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(guide.reflectionQuestions.count, 2)
    }

    func testEmptySummaryUsesDeterministicFallback() async throws {
        let content = StudyGuideGeneratedContent(
            summary: "   ",
            reflectionQuestions: ["What matters here?", "What will you do?"],
            source: .appleFoundationModels
        )
        let service = makeService(generator: StubStudyGuideContentGenerator(content: content))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
    }

    func testFewerThanTwoQuestionsUsesDeterministicFallback() async throws {
        let content = StudyGuideGeneratedContent(
            summary: "A concise summary.",
            reflectionQuestions: ["What matters here?"],
            source: .appleFoundationModels
        )
        let service = makeService(generator: StubStudyGuideContentGenerator(content: content))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(guide.reflectionQuestions.count, 2)
    }

    func testMoreThanTwoQuestionsUsesDeterministicFallback() async throws {
        let content = StudyGuideGeneratedContent(
            summary: "A concise summary.",
            reflectionQuestions: ["First?", "Second?", "Third?"],
            source: .appleFoundationModels
        )
        let service = makeService(generator: StubStudyGuideContentGenerator(content: content))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(guide.reflectionQuestions.count, 2)
    }

    func testGeneratedScriptureLikeOutputIsRejected() async throws {
        let passageText = try await bundledPassageText()
        let content = StudyGuideGeneratedContent(
            summary: passageText,
            reflectionQuestions: ["What stands out?", "What changes today?"],
            source: .appleFoundationModels
        )
        let service = makeService(generator: StubStudyGuideContentGenerator(content: content))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertNotEqual(guide.summary, passageText)
    }

    func testGeneratedReferenceIsRejected() async throws {
        let content = StudyGuideGeneratedContent(
            summary: "This points readers toward John 99:99.",
            reflectionQuestions: ["What stands out?", "What changes today?"],
            source: .appleFoundationModels
        )
        let service = makeService(generator: StubStudyGuideContentGenerator(content: content))

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertFalse(guide.summary?.contains("John 99:99") == true)
    }

    func testValidGeneratedContentCannotChangeBundledFieldsOrReferences() async throws {
        let expectedPassage = try await bundledPassageText()
        let expectedCommentary = TranslationService.shared.getVerseCommentary(
            for: reference.book,
            chapter: reference.chapter,
            verse: reference.verse
        )
        let service = makeService(
            generator: StubStudyGuideContentGenerator(content: validGeneratedContent())
        )

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .appleFoundationModels)
        XCTAssertEqual(guide.passageText, expectedPassage)
        XCTAssertEqual(guide.commentary, expectedCommentary)
        XCTAssertEqual(guide.sourceReferences, [reference])
        XCTAssertFalse(guide.relatedReferences.contains { $0.id == reference.id })
    }

    func testDeterministicFallbackIsStable() async throws {
        let input = StudyGuideContentInput(
            passageText: try await bundledPassageText(),
            commentary: TranslationService.shared.getVerseCommentary(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse
            )
        )
        let generator = DeterministicStudyGuideContentGenerator()

        let first = try await generator.generateContent(for: input)
        let second = try await generator.generateContent(for: input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.reflectionQuestions.count, 2)
    }

    func testDisabledFeatureUsesFallbackWithoutCallingModel() async throws {
        let generator = RecordingStudyGuideContentGenerator()
        let service = DefaultIntelligenceService(
            translationService: .shared,
            contentGenerator: generator,
            isFoundationModelsGenerationEnabled: false
        )

        let guide = try await service.studyGuide(for: reference)

        XCTAssertEqual(guide.source, .deterministicFallback)
        XCTAssertEqual(generator.callCount, 0)
    }

    func testProductionBuildDefaultDisablesFoundationModelsGeneration() {
        XCTAssertFalse(InternalFeatureFlags.studyGuideFoundationModelsEnabled(isDebugBuild: false))
        XCTAssertTrue(InternalFeatureFlags.studyGuideFoundationModelsEnabled(isDebugBuild: true))
    }

    func testMissingBundledPassageStillFailsBeforeGeneration() async {
        let missing = VerseReference(book: "John", chapter: 3, verse: 999)
        let generator = RecordingStudyGuideContentGenerator()
        let service = makeService(generator: generator)

        do {
            _ = try await service.studyGuide(for: missing)
            XCTFail("Expected missing bundled Scripture to fail.")
        } catch BibleError.verseNotFound {
            XCTAssertEqual(generator.callCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeService(
        generator: any StudyGuideContentGenerator,
        timeoutNanoseconds: UInt64 = 3_000_000_000
    ) -> DefaultIntelligenceService {
        DefaultIntelligenceService(
            translationService: .shared,
            contentGenerator: generator,
            isFoundationModelsGenerationEnabled: true,
            generationTimeoutNanoseconds: timeoutNanoseconds
        )
    }

    private func bundledPassageText() async throws -> String {
        try await TranslationService.shared.getVerseTranslation(
            for: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            translation: "AAVE"
        )
    }

    private func validGeneratedContent() -> StudyGuideGeneratedContent {
        StudyGuideGeneratedContent(
            summary: "The passage emphasizes love, purpose, and a faithful response.",
            reflectionQuestions: [
                "What part of this message challenges you most?",
                "How can this message shape one choice today?"
            ],
            source: .appleFoundationModels
        )
    }
}

@MainActor
private struct StubStudyGuideContentGenerator: StudyGuideContentGenerator {
    enum Behavior {
        case content(StudyGuideGeneratedContent)
        case delayed(nanoseconds: UInt64, content: StudyGuideGeneratedContent)
        case failure
    }

    let isAvailable: Bool
    let behavior: Behavior

    init(
        isAvailable: Bool = true,
        content: StudyGuideGeneratedContent = StudyGuideGeneratedContent(
            summary: "A valid summary.",
            reflectionQuestions: ["What stands out?", "What changes today?"],
            source: .appleFoundationModels
        )
    ) {
        self.isAvailable = isAvailable
        self.behavior = .content(content)
    }

    init(isAvailable: Bool = true, behavior: Behavior) {
        self.isAvailable = isAvailable
        self.behavior = behavior
    }

    func generateContent(for input: StudyGuideContentInput) async throws -> StudyGuideGeneratedContent {
        switch behavior {
        case .content(let content):
            return content
        case .delayed(let nanoseconds, let content):
            try await Task.sleep(nanoseconds: nanoseconds)
            return content
        case .failure:
            throw StudyGuideContentGenerationError.unavailable
        }
    }
}

@MainActor
private final class RecordingStudyGuideContentGenerator: StudyGuideContentGenerator {
    let isAvailable = true
    private(set) var callCount = 0

    func generateContent(for input: StudyGuideContentInput) async throws -> StudyGuideGeneratedContent {
        callCount += 1
        return StudyGuideGeneratedContent(
            summary: "A valid summary.",
            reflectionQuestions: ["What stands out?", "What changes today?"],
            source: .appleFoundationModels
        )
    }
}
