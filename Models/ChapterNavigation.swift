//
//  ChapterNavigation.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import Foundation

// Create a new type with a different name to avoid conflicts
struct ChapterNavigation: Equatable {
    let book: String
    let chapter: Int
    
    init(book: String, chapter: Int) {
        self.book = book
        self.chapter = chapter
    }
    // Implement Equatable
        static func == (lhs: ChapterNavigation, rhs: ChapterNavigation) -> Bool {
            return lhs.book == rhs.book && lhs.chapter == rhs.chapter
        }
}
