import Foundation

struct DailyVerseSelection: Hashable, Sendable {
    let verseId: String
    let reference: String
    let excerpt: String
    let fullText: String
    let versionUsed: VerseVersion
    let isJesusSaid: Bool
}

enum VerseOfDayProvider {
    private static let minimumUsefulRotationCount = 14

    private static let jesusSaidVerses: [VerseReference] = [
        VerseReference(book: "Matthew", chapter: 5, verse: 3),
        VerseReference(book: "Matthew", chapter: 5, verse: 4),
        VerseReference(book: "Matthew", chapter: 5, verse: 5),
        VerseReference(book: "Matthew", chapter: 5, verse: 6),
        VerseReference(book: "Matthew", chapter: 5, verse: 7),
        VerseReference(book: "Matthew", chapter: 5, verse: 8),
        VerseReference(book: "Matthew", chapter: 5, verse: 9),
        VerseReference(book: "Matthew", chapter: 5, verse: 10),
        VerseReference(book: "Matthew", chapter: 5, verse: 11),
        VerseReference(book: "Matthew", chapter: 5, verse: 12),
        VerseReference(book: "John", chapter: 3, verse: 16),
        VerseReference(book: "John", chapter: 14, verse: 6),
        VerseReference(book: "Matthew", chapter: 11, verse: 28),
        VerseReference(book: "Matthew", chapter: 11, verse: 29),
        VerseReference(book: "Matthew", chapter: 11, verse: 30)
    ]

    static func today(
        jesusSaidOnly: Bool,
        preferredVersion: VerseVersion,
        testament: String = "Both",
        book: String? = nil,
        date: Date = Date(),
        calendar: Calendar = .current
    ) async -> DailyVerseSelection? {
        guard let reference = reference(
            jesusSaidOnly: jesusSaidOnly,
            testament: testament,
            book: book,
            date: date,
            calendar: calendar
        ) else { return nil }

        let verseId = makeVerseId(for: reference)
        let textResult = await ScriptureStore.bestText(for: verseId, preferredVersion: preferredVersion)

        guard let textResult else { return nil }

        return DailyVerseSelection(
            verseId: verseId,
            reference: reference.displayString,
            excerpt: clippedExcerpt(textResult.text),
            fullText: textResult.text,
            versionUsed: textResult.versionUsed,
            isJesusSaid: jesusSaidOnly
        )
    }

    static func reference(
        jesusSaidOnly: Bool,
        testament: String = "Both",
        book: String? = nil,
        date: Date = Date(),
        calendar: Calendar = .current
    ) -> VerseReference? {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        var source = jesusSaidOnly ? jesusSaidVerses : PopularScriptures.popularVerses

        if !jesusSaidOnly {
            source = filteredDailyVerses(from: source, testament: testament, book: book)
        }

        guard !source.isEmpty else { return nil }

        let rotation = shuffledForDailyRotation(source, year: year)
        return rotation[(dayOfYear - 1) % rotation.count]
    }

    static func randomReference(
        jesusSaidOnly: Bool,
        testament: String = "Both",
        book: String? = nil,
        excluding excludedReference: VerseReference? = nil
    ) -> VerseReference? {
        var source = jesusSaidOnly ? jesusSaidVerses : PopularScriptures.popularVerses

        if !jesusSaidOnly {
            source = filteredDailyVerses(from: source, testament: testament, book: book)
        }

        guard !source.isEmpty else { return nil }

        if let excludedReference, source.count > 1 {
            source.removeAll { $0.id == excludedReference.id }
        }

        return source.randomElement()
    }

    static func reference(forVerseId verseId: String) -> VerseReference? {
        let parts = verseId.split(separator: "-")
        guard parts.count >= 3,
              let chapter = Int(parts[parts.count - 2]),
              let verse = Int(parts[parts.count - 1]) else { return nil }
        let book = parts.dropLast(2).joined(separator: " ")
        return VerseReference(book: book, chapter: chapter, verse: verse)
    }

    private static func makeVerseId(for reference: VerseReference) -> String {
        let bookPart = reference.book.replacingOccurrences(of: " ", with: "-")
        return "\(bookPart)-\(reference.chapter)-\(reference.verse)"
    }

    private static func filteredDailyVerses(from verses: [VerseReference], testament: String, book: String?) -> [VerseReference] {
        var testamentFiltered = verses

        if testament == "Old Testament" {
            testamentFiltered = testamentFiltered.filter { PopularScriptures.isOldTestament($0.book) }
        } else if testament == "New Testament" {
            testamentFiltered = testamentFiltered.filter { !PopularScriptures.isOldTestament($0.book) }
        }

        if let book, book != "Any" {
            let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
            let bookFiltered = testamentFiltered.filter { $0.book == canonicalBook }
            if bookFiltered.count >= minimumUsefulRotationCount {
                return bookFiltered
            }
        }

        return testamentFiltered.isEmpty ? verses : testamentFiltered
    }

    private static func shuffledForDailyRotation(_ verses: [VerseReference], year: Int) -> [VerseReference] {
        verses
            .enumerated()
            .sorted { lhs, rhs in
                stableDailySortKey(for: lhs.element, index: lhs.offset, year: year) <
                    stableDailySortKey(for: rhs.element, index: rhs.offset, year: year)
            }
            .map(\.element)
    }

    private static func stableDailySortKey(for reference: VerseReference, index: Int, year: Int) -> UInt64 {
        let seed = "\(year)|\(reference.book)|\(reference.chapter)|\(reference.verse)|\(index)"
        return seed.utf8.reduce(UInt64(1469598103934665603)) { hash, byte in
            (hash ^ UInt64(byte)) &* 1099511628211
        }
    }

    private static func clippedExcerpt(_ text: String) -> String {
        let cleaned = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        let maxLength = 120
        guard cleaned.count > maxLength else { return cleaned }
        let clipped = cleaned.prefix(maxLength)
        return String(clipped).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}
