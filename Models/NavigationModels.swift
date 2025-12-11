//
//  NavigationModels.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import Foundation
import SwiftUI

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

enum AppRoute: Hashable {
    case bible(bookID: String, chapter: Int, verse: Int?)
    case commentary(bookID: String, chapter: Int, verse: Int)
    case bookmarks
}

enum AppTab: String, Hashable {
    case bible, home, search, bookmarks, more
}

final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    
    func resetAndGoTo(_ route: AppRoute) {
        path = NavigationPath()
        path.append(route)
    }
    
    func push(_ route: AppRoute) {
        path.append(route)
    }
}
