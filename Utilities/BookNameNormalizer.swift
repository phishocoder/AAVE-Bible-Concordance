//
//  BookNameNormalizer.swift
//  AAVE Bible Concordance
//

import Foundation

enum BookNameNormalizer {
    private static let canonicalNames = BibleBooks.all
    private static let shortNames = BibleBooks.shortNames
    private static let aliasMap: [String: String] = [
        "psalm": "Psalms",
        "songofsongs": "Song of Solomon",
        "songofsolomon": "Song of Solomon"
    ]

    static func canonicalBookName(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalizedKey = normalizeKey(trimmed)
        if let direct = aliasMap[normalizedKey] {
            return direct
        }

        if let canonical = canonicalLookup[normalizedKey] {
            return canonical
        }

        return nil
    }

    private static let canonicalLookup: [String: String] = {
        var map: [String: String] = [:]
        for book in canonicalNames {
            map[normalizeKey(book)] = book
        }
        for (canonical, short) in shortNames {
            map[normalizeKey(short)] = canonical
        }
        return map
    }()

    private static func normalizeKey(_ input: String) -> String {
        let normalizedPrefix = normalizeLeadingOrdinal(input)
        let allowed = CharacterSet.alphanumerics
        let filtered = normalizedPrefix.lowercased().filter { char in
            char.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
        return filtered
    }

    private static func normalizeLeadingOrdinal(_ input: String) -> String {
        let parts = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .split(separator: " ")
        guard let first = parts.first else { return input }

        let ordinalMap: [Substring: String] = [
            "i": "1", "ii": "2", "iii": "3",
            "1": "1", "2": "2", "3": "3",
            "1st": "1", "2nd": "2", "3rd": "3",
            "first": "1", "second": "2", "third": "3"
        ]

        guard let normalized = ordinalMap[first] else { return input }
        let remainder = parts.dropFirst().joined(separator: " ")
        if remainder.isEmpty {
            return normalized
        }
        return "\(normalized) \(remainder)"
    }
}

#if DEBUG
func assertCanonicalBook(_ book: String, context: String = "") {
    let isCanonical = BibleBooks.all.contains(book) || chapterVerseCount.keys.contains(book)
    assert(isCanonical, "Non-canonical book name '\(book)' \(context)")
}
#endif
