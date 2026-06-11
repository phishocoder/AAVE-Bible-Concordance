//
//  SearchResult.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import Foundation

enum SearchResultKind: Sendable {
    case verse
    case chapter
    case book
}

enum SearchMatchRank: Int, Comparable, Sendable {
    case exactReference
    case exactPhrase
    case wholeWord
    case allTokens
    case partialTokens

    static func < (lhs: SearchMatchRank, rhs: SearchMatchRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct SearchResult: Identifiable, Sendable {
    let book: String
    let chapter: Int?
    let verse: Int?
    let kind: SearchResultKind
    let aaveText: String
    let traditionalText: String
    
    var id: String {
        let ch = chapter.map(String.init) ?? ""
        let vs = verse.map(String.init) ?? ""
        return "\(kind)-\(book)-\(ch)-\(vs)".lowercased()
    }
    
    var text: String {
        if !aaveText.isEmpty { return aaveText }
        if !traditionalText.isEmpty { return traditionalText }
        return ""
    }

    var displayTitle: String {
        switch kind {
        case .book:
            return book
        case .chapter:
            if let chapter {
                return "\(book) \(chapter)"
            }
            return book
        case .verse:
            if let chapter, let verse {
                return "\(book) \(chapter):\(verse)"
            }
            return book
        }
    }

    var previewText: String? {
        let resolved = text
        return resolved.isEmpty ? nil : resolved
    }
    
    var reference: VerseReference? {
        guard kind == .verse, let chapter, let verse, verse > 0 else { return nil }
        return VerseReference(book: book, chapter: chapter, verse: verse)
    }
    
    var resolvedChapter: Int {
        max(1, chapter ?? 1)
    }

    var resolvedVerse: Int? {
        guard kind == .verse, let verse, verse > 0 else { return nil }
        return verse
    }
    
    init(
        book: String,
        chapter: Int?,
        verse: Int?,
        kind: SearchResultKind = .verse,
        aaveText: String,
        traditionalText: String
    ) {
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.kind = kind
        self.aaveText = aaveText
        self.traditionalText = traditionalText
    }
}

struct SearchResultPage: Sendable {
    let results: [SearchResult]
    let totalCount: Int
    let limit: Int
    let rankingSource: SearchRankingSource

    init(
        results: [SearchResult],
        totalCount: Int,
        limit: Int,
        rankingSource: SearchRankingSource = .lexical
    ) {
        self.results = results
        self.totalCount = totalCount
        self.limit = limit
        self.rankingSource = rankingSource
    }

    var isLimited: Bool {
        totalCount > results.count
    }

    static func empty(limit: Int) -> SearchResultPage {
        SearchResultPage(results: [], totalCount: 0, limit: limit)
    }
}

enum SearchRankingSource: Equatable, Sendable {
    case lexical
    case aiAssisted
    case aiFallback

#if DEBUG
    var experimentalDisplayName: String {
        switch self {
        case .lexical:
            return "Lexical ranking"
        case .aiAssisted:
            return "Experimental AI-assisted ranking"
        case .aiFallback:
            return "Lexical fallback after experimental AI failure"
        }
    }
#endif
}

struct SearchResultRanker {
    static func rankedPage(
        query: String,
        candidates: [SearchResult],
        limit: Int
    ) -> SearchResultPage {
        let safeLimit = max(0, limit)
        let ranked = candidates.compactMap { result -> (SearchResult, SearchMatchRank)? in
            guard let rank = rank(for: result, query: query) else { return nil }
            return (result, rank)
        }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 {
                return lhs.1 < rhs.1
            }
            return isBeforeInBible(lhs.0, rhs.0)
        }

        return SearchResultPage(
            results: ranked.prefix(safeLimit).map(\.0),
            totalCount: ranked.count,
            limit: safeLimit
        )
    }

    static func rank(for result: SearchResult, query: String) -> SearchMatchRank? {
        let queryWords = words(in: query)
        guard !queryWords.isEmpty else { return nil }

        if normalizedReference(result.displayTitle) == normalizedReference(query) {
            return .exactReference
        }

        let textWords = words(in: result.text)
        guard !textWords.isEmpty else { return nil }

        if textWords == queryWords || (queryWords.count > 1 && containsSequence(queryWords, in: textWords)) {
            return .exactPhrase
        }

        if queryWords.count == 1, textWords.contains(queryWords[0]) {
            return .wholeWord
        }

        if queryWords.count > 1, queryWords.allSatisfy(textWords.contains) {
            return .allTokens
        }

        if queryWords.allSatisfy({ queryWord in
            textWords.contains { $0.contains(queryWord) }
        }) {
            return .partialTokens
        }

        return nil
    }

    private static func words(in value: String) -> [String] {
        value
            .lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" })
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    private static func normalizedReference(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    private static func containsSequence(_ needle: [String], in haystack: [String]) -> Bool {
        guard needle.count <= haystack.count else { return false }
        for startIndex in 0...(haystack.count - needle.count) {
            if Array(haystack[startIndex..<(startIndex + needle.count)]) == needle {
                return true
            }
        }
        return false
    }

    private static func isBeforeInBible(_ lhs: SearchResult, _ rhs: SearchResult) -> Bool {
        let unknownBookIndex = BibleBooks.all.count
        let lhsBookIndex = BibleBooks.all.firstIndex(of: lhs.book) ?? unknownBookIndex
        let rhsBookIndex = BibleBooks.all.firstIndex(of: rhs.book) ?? unknownBookIndex

        if lhsBookIndex != rhsBookIndex {
            return lhsBookIndex < rhsBookIndex
        }
        if lhs.resolvedChapter != rhs.resolvedChapter {
            return lhs.resolvedChapter < rhs.resolvedChapter
        }
        if (lhs.resolvedVerse ?? 0) != (rhs.resolvedVerse ?? 0) {
            return (lhs.resolvedVerse ?? 0) < (rhs.resolvedVerse ?? 0)
        }
        return lhs.id < rhs.id
    }
}
