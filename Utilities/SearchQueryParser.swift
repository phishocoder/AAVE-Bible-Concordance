//
//  SearchQueryParser.swift
//  AAVE Bible Concordance
//

import Foundation

struct SearchQueryParser {
    private static let normalizedBookMap: [String: String] = {
        var map: [String: String] = [:]
        for book in BibleBooks.all {
            let normalized = normalize(book)
            map[normalized] = book
            map[normalized.replacingOccurrences(of: " ", with: "")] = book
        }
        for (book, short) in BibleBooks.shortNames {
            map[normalize(short)] = book
        }
        return map
    }()
    
    static func parseReference(from query: String) -> VerseReference? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let pattern = #"^\s*([1-3]?\s*[A-Za-z\. ]+?)\s*(\d+)(?:[:\.](\d+))?\s*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else {
            return nil
        }
        guard match.numberOfRanges >= 3,
              let bookRange = Range(match.range(at: 1), in: trimmed),
              let chapterRange = Range(match.range(at: 2), in: trimmed) else {
            return nil
        }
        let bookCandidate = trimmed[bookRange]
        let chapterString = trimmed[chapterRange]
        let verseString: Substring?
        if match.numberOfRanges > 3,
           let verseRange = Range(match.range(at: 3), in: trimmed) {
            verseString = trimmed[verseRange]
        } else {
            verseString = nil
        }
        guard let book = normalizeBookName(String(bookCandidate)) else { return nil }
        guard let chapter = Int(chapterString) else { return nil }
        guard let verseComponent = verseString,
              let verse = Int(verseComponent) else { return nil }
        return VerseReference(book: book, chapter: chapter, verse: verse)
    }
    
    private static func normalizeBookName(_ input: String) -> String? {
        let normalized = normalize(input)
        if let book = normalizedBookMap[normalized] {
            return book
        }
        let compact = normalized.replacingOccurrences(of: " ", with: "")
        return normalizedBookMap[compact]
    }
    
    private static func normalize(_ text: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let filtered = text.lowercased().filter { char in
            char.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
        return filtered
    }
}
