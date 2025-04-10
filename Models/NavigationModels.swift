//
//  NavigationModels.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import Foundation

// Navigation models for the app
struct BookChapterPair: Hashable, Equatable {
    let book: String
    let chapter: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(book)
        hasher.combine(chapter)
    }
    
    static func == (lhs: BookChapterPair, rhs: BookChapterPair) -> Bool {
        return lhs.book == rhs.book && lhs.chapter == rhs.chapter
    }
}

enum NavigationRequest: Equatable {
    case book(String)
    case chapter(String, Int)
    case verse(String, Int, Int)
    case search(String)
    case settings
    case bookmarks
    case home
}
