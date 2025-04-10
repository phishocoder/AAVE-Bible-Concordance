//
//  BookmarkView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct BookmarkView: View {
    @ObservedObject private var bookmarks = Bookmarks.shared
    @State private var searchText = ""
    
    var filteredBookmarks: [Bookmarks.BookmarkItem] {
        if searchText.isEmpty {
            return bookmarks.bookmarks
        } else {
            return bookmarks.bookmarks.filter { bookmark in
                bookmark.displayTitle.localizedCaseInsensitiveContains(searchText) ||
                bookmark.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredBookmarks) { bookmark in
                NavigationLink(destination: VerseDetailView(reference: VerseReference(
                    book: bookmark.book,
                    chapter: bookmark.chapter,
                    verse: bookmark.verse
                ))) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(bookmark.displayTitle)
                                .font(.headline)
                            Spacer()
                            Text(bookmark.dateAdded.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(bookmark.text)
                            .font(.body)
                            .lineLimit(3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        bookmarks.removeBookmark(withId: bookmark.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
        .searchable(text: $searchText, prompt: "Search bookmarks")
        .overlay {
            if bookmarks.bookmarks.isEmpty {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "bookmark.slash",
                    description: Text("Your saved verses will appear here")
                )
            } else if filteredBookmarks.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search term")
                )
            }
        }
    }
}
