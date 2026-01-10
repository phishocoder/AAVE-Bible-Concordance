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
