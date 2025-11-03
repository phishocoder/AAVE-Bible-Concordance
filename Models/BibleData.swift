//
//  BibleData.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import Foundation

/// Convenience wrapper around core Bible metadata so legacy call-sites can query books and verse counts.
enum BibleData {
    /// Returns the ordered list of books with their chapter counts and applicable testament.
    static var books: [BibleBook] { bibleBooks }
    
    /// Backing dictionary that maps `[Book: [Chapter: VerseCount]]`.
    static var chapterVerseCounts: [String: [Int: Int]] { chapterVerseCount }
    
    /// Returns the number of verses for the requested book/chapter pair if available.
    static func verseCount(for book: String, chapter: Int) -> Int? {
        chapterVerseCounts[book]?[chapter]
    }
    
    /// Returns all books for a given testament, preserving canonical order.
    static func books(for testament: Testament) -> [BibleBook] {
        books.filter { $0.testament == testament }
    }
}

/// Validates whether a verse reference exists within the known canon.
/// - Parameters:
///   - book: Canonical book name.
///   - chapter: 1-based chapter index.
///   - verse: 1-based verse index.
/// - Returns: `true` when the reference is valid.
@discardableResult
func validateVerseCount(book: String, chapter: Int, verse: Int) -> Bool {
    guard !book.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          chapter > 0,
          verse > 0,
          let chapterMapping = chapterVerseCount[book],
          let maxVerse = chapterMapping[chapter] else {
        return false
    }
    return verse <= maxVerse
}
