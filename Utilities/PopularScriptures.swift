//
//  PopularScriptures.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import Foundation
import SwiftUI

class PopularScriptures {
    static let popularVerses: [VerseReference] = [
        VerseReference(book: "John", chapter: 3, verse: 16),
        VerseReference(book: "Genesis", chapter: 1, verse: 1),
        VerseReference(book: "Exodus", chapter: 14, verse: 14),
        VerseReference(book: "Psalms", chapter: 23, verse: 1),
        VerseReference(book: "Proverbs", chapter: 3, verse: 5),
        VerseReference(book: "Isaiah", chapter: 40, verse: 31),
        VerseReference(book: "Jeremiah", chapter: 29, verse: 11),
        VerseReference(book: "Romans", chapter: 8, verse: 28),
        VerseReference(book: "Philippians", chapter: 4, verse: 13),
        VerseReference(book: "Matthew", chapter: 28, verse: 19),
        VerseReference(book: "1 Corinthians", chapter: 13, verse: 4),
        VerseReference(book: "Galatians", chapter: 5, verse: 22),
        VerseReference(book: "Hebrews", chapter: 11, verse: 1),
        VerseReference(book: "James", chapter: 1, verse: 2),
        VerseReference(book: "1 Peter", chapter: 5, verse: 7),
        VerseReference(book: "1 John", chapter: 4, verse: 7),
        VerseReference(book: "Revelation", chapter: 21, verse: 4)
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
