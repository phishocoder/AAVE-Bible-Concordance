//
//  SearchQueryParser.swift
//  AAVE Bible Concordance
//

import Foundation

struct ParsedReference: Sendable, Hashable {
    let book: String
    let chapter: Int?
    let verse: Int?
}

struct SearchQueryParser {
    static func parseReference(from query: String) -> ParsedReference? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let pattern = #"^\s*([1-3]?\s*[A-Za-z\. ]+?)\s*(?:(\d+)(?:\s*[:\.]?\s*(\d+))?)?\s*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range) else {
            return nil
        }
        guard match.numberOfRanges >= 2,
              let bookRange = Range(match.range(at: 1), in: trimmed) else {
            return nil
        }
        let bookCandidate = trimmed[bookRange]
        guard let book = normalizeBookName(String(bookCandidate)) else { return nil }
        let chapter: Int?
        if match.numberOfRanges > 2,
           let chapterRange = Range(match.range(at: 2), in: trimmed),
           let chapterValue = Int(trimmed[chapterRange]) {
            chapter = chapterValue
        } else {
            chapter = nil
        }
        let verse: Int?
        if match.numberOfRanges > 3,
           let verseRange = Range(match.range(at: 3), in: trimmed),
           let verseValue = Int(trimmed[verseRange]) {
            verse = verseValue
        } else {
            verse = nil
        }
        return ParsedReference(book: book, chapter: chapter, verse: verse)
    }
    
    private static func normalizeBookName(_ input: String) -> String? {
        BookNameNormalizer.canonicalBookName(input)
    }
}
