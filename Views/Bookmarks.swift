//
//  Bookmarks.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//
import Foundation
import SwiftUI

@MainActor
class Bookmarks: ObservableObject {
    static let shared = Bookmarks()
    
    @Published private(set) var bookmarks: [BookmarkItem] = []
    private let bookmarksKey = "savedBookmarks"
    
    private init() {
        loadBookmarks()
    }
    
    struct BookmarkItem: Codable, Identifiable {
        let id: UUID
        let book: String
        let chapter: Int
        let verse: Int
        let text: String
        let dateAdded: Date
        
        var displayTitle: String {
            "\(book) \(chapter):\(verse)"
        }
    }
    
    func addBookmark(book: String, chapter: Int, verse: Int, text: String) {
        let bookmark = BookmarkItem(
            id: UUID(),
            book: book,
            chapter: chapter,
            verse: verse,
            text: text,
            dateAdded: Date()
        )
        
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func removeBookmark(at index: Int) {
        bookmarks.remove(at: index)
        saveBookmarks()
    }
    
    func removeBookmark(withId id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveBookmarks()
    }

    func clearAllBookmarks() {
        bookmarks.removeAll()
        saveBookmarks()
    }
    
    func isBookmarked(book: String, chapter: Int, verse: Int) -> Bool {
        bookmarks.contains { bookmark in
            bookmark.book == book &&
            bookmark.chapter == chapter &&
            bookmark.verse == verse
        }
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }
    
    private func loadBookmarks() {
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([BookmarkItem].self, from: data) {
            bookmarks = decoded
        }
    }
}
