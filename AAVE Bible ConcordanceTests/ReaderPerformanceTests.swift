import XCTest
@testable import AAVE_Bible_Concordance

final class ReaderPerformanceTests: XCTestCase {
    func testChapterCacheEvictsLeastRecentlyUsedChapter() {
        var cache = ChapterVerseCache(capacity: 3)
        let genesis1 = ChapterCacheKey(book: "Genesis", chapter: 1, translation: "AAVE")
        let genesis2 = ChapterCacheKey(book: "Genesis", chapter: 2, translation: "AAVE")
        let genesis3 = ChapterCacheKey(book: "Genesis", chapter: 3, translation: "AAVE")
        let genesis4 = ChapterCacheKey(book: "Genesis", chapter: 4, translation: "AAVE")

        cache.insert([], for: genesis1)
        cache.insert([], for: genesis2)
        cache.insert([], for: genesis3)
        _ = cache.value(for: genesis1)
        cache.insert([], for: genesis4)

        XCTAssertTrue(cache.contains(genesis1))
        XCTAssertFalse(cache.contains(genesis2))
        XCTAssertTrue(cache.contains(genesis3))
        XCTAssertTrue(cache.contains(genesis4))
        XCTAssertEqual(cache.storage.count, 3)
    }

    @MainActor
    func testAdjacentChaptersCrossBookBoundaries() {
        let references = VerseManager.adjacentChapterReferences(book: "Exodus", chapter: 1)

        XCTAssertEqual(references.count, 2)
        XCTAssertEqual(references[0].book, "Genesis")
        XCTAssertEqual(references[0].chapter, 50)
        XCTAssertEqual(references[1].book, "Exodus")
        XCTAssertEqual(references[1].chapter, 2)
    }

    @MainActor
    func testFirstAndLastBibleChaptersOnlyHaveOneAdjacentChapter() {
        let first = VerseManager.adjacentChapterReferences(book: "Genesis", chapter: 1)
        let last = VerseManager.adjacentChapterReferences(book: "Revelation", chapter: 22)

        XCTAssertEqual(first.count, 1)
        XCTAssertEqual(first[0].book, "Genesis")
        XCTAssertEqual(first[0].chapter, 2)
        XCTAssertEqual(last.count, 1)
        XCTAssertEqual(last[0].book, "Revelation")
        XCTAssertEqual(last[0].chapter, 21)
    }

    @MainActor
    func testPreloadingKeepsOnlyCurrentAndAdjacentChapters() async throws {
        try await TranslationService.shared.loadTranslations()
        let manager = VerseManager.shared
        manager.resetChapterCacheForTesting()

        _ = try await manager.getChapterVerses(book: "John", chapter: 3, translation: "AAVE")
        await manager.preloadAdjacentChapters(book: "John", chapter: 3, translation: "AAVE")

        XCTAssertTrue(manager.isChapterCachedForTesting(book: "John", chapter: 2, translation: "AAVE"))
        XCTAssertTrue(manager.isChapterCachedForTesting(book: "John", chapter: 3, translation: "AAVE"))
        XCTAssertTrue(manager.isChapterCachedForTesting(book: "John", chapter: 4, translation: "AAVE"))
        XCTAssertEqual(manager.chapterCacheCountForTesting, 3)
    }
}
