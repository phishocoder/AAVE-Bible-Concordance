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

enum NotificationVerseRouteParser {
    static func route(from userInfo: [AnyHashable: Any]) -> AppRoute? {
        guard let rawBook = userInfo["book"] as? String,
              let chapter = intValue(userInfo["chapter"]),
              let verse = intValue(userInfo["verse"]) else {
            return nil
        }

        return route(book: rawBook, chapter: chapter, verse: verse)
    }

    static func route(from url: URL) -> AppRoute? {
        guard url.scheme?.caseInsensitiveCompare("aavebible") == .orderedSame,
              url.host?.caseInsensitiveCompare("verse") == .orderedSame else {
            return nil
        }

        let pathParts = url.path.split(separator: "/", omittingEmptySubsequences: true)
        guard pathParts.count == 1 else { return nil }

        let verseIDParts = pathParts[0].split(separator: "-", omittingEmptySubsequences: true)
        guard verseIDParts.count >= 3,
              let chapter = Int(verseIDParts[verseIDParts.count - 2]),
              let verse = Int(verseIDParts[verseIDParts.count - 1]) else {
            return nil
        }

        let rawBook = verseIDParts.dropLast(2).joined(separator: " ")
        return route(book: rawBook, chapter: chapter, verse: verse)
    }

    private static func route(book rawBook: String, chapter: Int, verse: Int) -> AppRoute? {
        guard let book = BookNameNormalizer.canonicalBookName(rawBook),
              validateVerseCount(book: book, chapter: chapter, verse: verse) else {
            return nil
        }

        return .bible(bookID: book, chapter: chapter, verse: verse)
    }

    private static func intValue(_ rawValue: Any?) -> Int? {
        switch rawValue {
        case let value as Int:
            return value
        case let value as NSNumber:
            return value.intValue
        case let value as String:
            return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            return nil
        }
    }
}

@MainActor
final class NotificationNavigationBridge: ObservableObject {
    static let shared = NotificationNavigationBridge()

    @Published private(set) var pendingRoute: AppRoute?

    private init() {}

    func enqueue(_ route: AppRoute) {
#if DEBUG
        if case let .bible(bookID, chapter, verse) = route {
            assertCanonicalBook(bookID, context: "NotificationNavigationBridge.enqueue chapter=\(chapter) verse=\(String(describing: verse))")
        }
#endif
        pendingRoute = route
    }

    func consume() -> AppRoute? {
        let route = pendingRoute
        pendingRoute = nil
        return route
    }
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
