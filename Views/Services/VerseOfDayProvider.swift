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
    private static let dailyVerses: [VerseReference] = [
        VerseReference(book: "Matthew", chapter: 8, verse: 2),
        VerseReference(book: "Psalms", chapter: 23, verse: 1),
        VerseReference(book: "Romans", chapter: 8, verse: 28),
        VerseReference(book: "Isaiah", chapter: 41, verse: 10),
        VerseReference(book: "John", chapter: 3, verse: 16)
    ]

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
        var source = jesusSaidOnly ? jesusSaidVerses : dailyVerses

        if !jesusSaidOnly {
            source = filteredDailyVerses(from: source, testament: testament, book: book)
        }

        guard !source.isEmpty else { return nil }

        return source[(dayOfYear - 1) % source.count]
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
        var filtered = verses

        if testament == "Old Testament" {
            filtered = filtered.filter { PopularScriptures.isOldTestament($0.book) }
        } else if testament == "New Testament" {
            filtered = filtered.filter { !PopularScriptures.isOldTestament($0.book) }
        }

        if let book, book != "Any" {
            let canonicalBook = BookNameNormalizer.canonicalBookName(book) ?? book
            let bookFiltered = filtered.filter { $0.book == canonicalBook }
            filtered = bookFiltered.isEmpty ? verses : bookFiltered
        }

        return filtered.isEmpty ? verses : filtered
    }

    private static func clippedExcerpt(_ text: String) -> String {
        let cleaned = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        let maxLength = 120
        guard cleaned.count > maxLength else { return cleaned }
        let clipped = cleaned.prefix(maxLength)
        return String(clipped).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}
