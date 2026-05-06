//
//  PopularScriptures.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import Foundation
import SwiftUI

class PopularScriptures {
    // Based on Bible Gateway's published Top 100 most-read verses list.
    static let popularVerses: [VerseReference] = [
        VerseReference(book: "Psalms", chapter: 23, verse: 4),
        VerseReference(book: "Psalms", chapter: 23, verse: 6),
        VerseReference(book: "Psalms", chapter: 23, verse: 5),
        VerseReference(book: "Psalms", chapter: 23, verse: 1),
        VerseReference(book: "Psalms", chapter: 23, verse: 3),
        VerseReference(book: "Psalms", chapter: 23, verse: 2),
        VerseReference(book: "Jeremiah", chapter: 29, verse: 11),
        VerseReference(book: "John", chapter: 3, verse: 16),
        VerseReference(book: "Psalms", chapter: 91, verse: 11),
        VerseReference(book: "Psalms", chapter: 91, verse: 1),
        VerseReference(book: "Psalms", chapter: 91, verse: 2),
        VerseReference(book: "Psalms", chapter: 91, verse: 4),
        VerseReference(book: "Psalms", chapter: 91, verse: 12),
        VerseReference(book: "Psalms", chapter: 91, verse: 15),
        VerseReference(book: "Psalms", chapter: 91, verse: 16),
        VerseReference(book: "Psalms", chapter: 91, verse: 14),
        VerseReference(book: "Psalms", chapter: 91, verse: 7),
        VerseReference(book: "Psalms", chapter: 91, verse: 10),
        VerseReference(book: "Psalms", chapter: 91, verse: 9),
        VerseReference(book: "Psalms", chapter: 91, verse: 8),
        VerseReference(book: "Psalms", chapter: 91, verse: 5),
        VerseReference(book: "Psalms", chapter: 91, verse: 13),
        VerseReference(book: "Psalms", chapter: 91, verse: 3),
        VerseReference(book: "Psalms", chapter: 91, verse: 6),
        VerseReference(book: "Joshua", chapter: 1, verse: 9),
        VerseReference(book: "Isaiah", chapter: 41, verse: 10),
        VerseReference(book: "Romans", chapter: 8, verse: 28),
        VerseReference(book: "John", chapter: 14, verse: 6),
        VerseReference(book: "Romans", chapter: 12, verse: 2),
        VerseReference(book: "Matthew", chapter: 6, verse: 33),
        VerseReference(book: "Ephesians", chapter: 6, verse: 12),
        VerseReference(book: "Philippians", chapter: 4, verse: 6),
        VerseReference(book: "Philippians", chapter: 4, verse: 13),
        VerseReference(book: "Philippians", chapter: 4, verse: 7),
        VerseReference(book: "John", chapter: 16, verse: 33),
        VerseReference(book: "Philippians", chapter: 4, verse: 8),
        VerseReference(book: "Isaiah", chapter: 40, verse: 31),
        VerseReference(book: "Proverbs", chapter: 3, verse: 5),
        VerseReference(book: "Proverbs", chapter: 3, verse: 6),
        VerseReference(book: "1 Peter", chapter: 5, verse: 7),
        VerseReference(book: "Isaiah", chapter: 54, verse: 17),
        VerseReference(book: "2 Timothy", chapter: 1, verse: 7),
        VerseReference(book: "2 Corinthians", chapter: 5, verse: 17),
        VerseReference(book: "Matthew", chapter: 11, verse: 28),
        VerseReference(book: "John", chapter: 10, verse: 10),
        VerseReference(book: "Matthew", chapter: 28, verse: 20),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 4),
        VerseReference(book: "2 Corinthians", chapter: 12, verse: 9),
        VerseReference(book: "Galatians", chapter: 5, verse: 22),
        VerseReference(book: "John", chapter: 14, verse: 27),
        VerseReference(book: "Psalms", chapter: 121, verse: 8),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 7),
        VerseReference(book: "Matthew", chapter: 28, verse: 19),
        VerseReference(book: "Psalms", chapter: 121, verse: 7),
        VerseReference(book: "Psalms", chapter: 121, verse: 2),
        VerseReference(book: "Psalms", chapter: 1, verse: 3),
        VerseReference(book: "Romans", chapter: 12, verse: 1),
        VerseReference(book: "Psalms", chapter: 121, verse: 3),
        VerseReference(book: "Psalms", chapter: 121, verse: 1),
        VerseReference(book: "Psalms", chapter: 121, verse: 4),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 5),
        VerseReference(book: "Psalms", chapter: 121, verse: 5),
        VerseReference(book: "Psalms", chapter: 121, verse: 6),
        VerseReference(book: "2 Timothy", chapter: 3, verse: 16),
        VerseReference(book: "Galatians", chapter: 5, verse: 23),
        VerseReference(book: "Psalms", chapter: 1, verse: 2),
        VerseReference(book: "Psalms", chapter: 1, verse: 1),
        VerseReference(book: "Genesis", chapter: 1, verse: 27),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 6),
        VerseReference(book: "1 John", chapter: 1, verse: 9),
        VerseReference(book: "1 Thessalonians", chapter: 5, verse: 18),
        VerseReference(book: "Psalms", chapter: 46, verse: 10),
        VerseReference(book: "2 Corinthians", chapter: 10, verse: 5),
        VerseReference(book: "2 Chronicles", chapter: 7, verse: 14),
        VerseReference(book: "1 Peter", chapter: 2, verse: 9),
        VerseReference(book: "Ephesians", chapter: 2, verse: 10),
        VerseReference(book: "Psalms", chapter: 139, verse: 14),
        VerseReference(book: "Hebrews", chapter: 4, verse: 12),
        VerseReference(book: "Ephesians", chapter: 3, verse: 20),
        VerseReference(book: "Matthew", chapter: 11, verse: 29),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 8),
        VerseReference(book: "Ephesians", chapter: 2, verse: 8),
        VerseReference(book: "Ephesians", chapter: 6, verse: 11),
        VerseReference(book: "Isaiah", chapter: 53, verse: 5),
        VerseReference(book: "Psalms", chapter: 1, verse: 6),
        VerseReference(book: "1 Corinthians", chapter: 10, verse: 13),
        VerseReference(book: "Psalms", chapter: 1, verse: 4),
        VerseReference(book: "Psalms", chapter: 100, verse: 4),
        VerseReference(book: "Psalms", chapter: 1, verse: 5),
        VerseReference(book: "Romans", chapter: 5, verse: 8),
        VerseReference(book: "Jeremiah", chapter: 33, verse: 3),
        VerseReference(book: "1 Peter", chapter: 5, verse: 8),
        VerseReference(book: "Galatians", chapter: 6, verse: 9),
        VerseReference(book: "Hebrews", chapter: 12, verse: 2),
        VerseReference(book: "Colossians", chapter: 3, verse: 23),
        VerseReference(book: "Hebrews", chapter: 11, verse: 1),
        VerseReference(book: "Philippians", chapter: 4, verse: 19),
        VerseReference(book: "Romans", chapter: 3, verse: 23),
        VerseReference(book: "Acts", chapter: 1, verse: 8),
        VerseReference(book: "Genesis", chapter: 1, verse: 26)
    ]
    
    // Old Testament books
    private static let oldTestamentBooks = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
        "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
        "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
        "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
        "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah",
        "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
        "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah",
        "Haggai", "Zechariah", "Malachi"
    ]
    
    // Check if a book is in the Old Testament
    static func isOldTestament(_ book: String) -> Bool {
        return oldTestamentBooks.contains(book)
    }
    
    // Update the getVerseOfTheDay function
    static func getVerseOfTheDay(testament: String = "Both", book: String? = nil) -> VerseReference {
        // Filter verses based on testament
        var filteredVerses: [VerseReference]
        
        if testament == "Old Testament" {
            filteredVerses = popularVerses.filter { isOldTestament($0.book) }
        } else if testament == "New Testament" {
            filteredVerses = popularVerses.filter { !isOldTestament($0.book) }
        } else {
            filteredVerses = popularVerses
        }
        
        // Further filter by book if specified
        if let book = book, book != "Any" {
            filteredVerses = filteredVerses.filter { $0.book == book }
            
            // If no verses match the book, fall back to all verses
            if filteredVerses.isEmpty {
                filteredVerses = popularVerses
            }
        }
        
        // Get a random verse from the filtered list
        let randomIndex = Int.random(in: 0..<filteredVerses.count)
        return filteredVerses[randomIndex]
    }
    
    // Get a random verse from a specific book
    static func getRandomVerse(from book: String) -> VerseReference? {
        let versesFromBook = popularVerses.filter { $0.book == book }
        guard !versesFromBook.isEmpty else { return nil }
        
        let randomIndex = Int.random(in: 0..<versesFromBook.count)
        return versesFromBook[randomIndex]
    }
}
