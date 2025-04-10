//
//  RedLetterService.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/10/25.
//

import Foundation

class RedLetterService {
    static let shared = RedLetterService()
    
    private let translationService = TranslationService.shared
    
    // Dictionary mapping books to chapters with red letter verses
    private let redLetterBooks = [
        "Matthew": Set(1...28),
        "Mark": Set(1...16),
        "Luke": Set(1...24),
        "John": Set(1...21),
        "Acts": Set([1]) // Jesus speaks in Acts 1 (before ascension)
    ]
    
    // Known red letter verses (for demo/testing)
    private let knownRedLetterVerses: [VerseReference] = [
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
    
    private init() {}
    
    func getRandomRedLetterVerse() -> VerseReference {
        // For now, return a random verse from our known list
        // In a full implementation, this would search the database for verses with <red> tags
        return knownRedLetterVerses.randomElement() ?? VerseReference(book: "Matthew", chapter: 5, verse: 3)
    }
    
    func isRedLetterVerse(_ reference: VerseReference) -> Bool {
        // Check if the book is in our red letter books
        guard let chapters = redLetterBooks[reference.book],
              chapters.contains(reference.chapter) else {
            return false
        }
        
        // For now, just check against our known list
        // In a full implementation, this would check the database
        return knownRedLetterVerses.contains {
            $0.book == reference.book &&
            $0.chapter == reference.chapter &&
            $0.verse == reference.verse
        }
    }
    
    func getRedLetterVerses(in book: String, chapter: Int) async -> [Int] {
        // For now, filter our known list
        // In a full implementation, this would query the database
        return knownRedLetterVerses
            .filter { $0.book == book && $0.chapter == chapter }
            .map { $0.verse }
    }
}
