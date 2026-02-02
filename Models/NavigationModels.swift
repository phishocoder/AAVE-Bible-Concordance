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
    case bookChapters(bookID: String)
    case bible(bookID: String, chapter: Int, verse: Int?)
    case commentary(bookID: String, chapter: Int, verse: Int)
    case verseDetail(reference: VerseReference)
    case bookmarks
}

enum AppTab: String, Hashable {
    case bible, home, search, bookmarks, more
}

final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var pendingDeepLink: AppRoute? = nil
    
    func resetAndGoTo(_ route: AppRoute) {
#if DEBUG
        debugValidateBibleRoute(route)
#endif
        path = NavigationPath()
        path.append(route)
    }
    
    func push(_ route: AppRoute) {
#if DEBUG
        debugValidateBibleRoute(route)
#endif
        path.append(route)
    }
    
    func requestDeepLink(_ route: AppRoute) {
#if DEBUG
        debugValidateBibleRoute(route)
#endif
        pendingDeepLink = route
    }

#if DEBUG
    private func debugValidateBibleRoute(_ route: AppRoute) {
        guard case let .bible(bookID, chapter, verse) = route else { return }
        assertCanonicalBook(bookID, context: "AppRoute.bible bookID=\(bookID) chapter=\(chapter) verse=\(String(describing: verse))")
    }
#endif
}
