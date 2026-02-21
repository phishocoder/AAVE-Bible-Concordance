//
//  BookmarkView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct BookmarkView: View {
    @Binding var selectedTab: AppTab
    @ObservedObject private var bookmarks = Bookmarks.shared
    @State private var searchText = ""
    @EnvironmentObject private var router: NavigationRouter
    
    init(selectedTab: Binding<AppTab>) {
        _selectedTab = selectedTab
    }
    
    init() {
        _selectedTab = Binding.constant(AppTab.bible)
    }
    
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
                Button {
                    selectedTab = .bible
                    let canonicalBook = BookNameNormalizer.canonicalBookName(bookmark.book) ?? bookmark.book
#if DEBUG
                    assertCanonicalBook(canonicalBook, context: "BookmarkView")
#endif
                    router.resetAndGoTo(
                        .bible(
                            bookID: canonicalBook,
                            chapter: bookmark.chapter,
                            verse: bookmark.verse
                        )
                    )
                } label: {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .homeCard()
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .swipeActions {
                    Button(role: .destructive) {
                        bookmarks.removeBookmark(withId: bookmark.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .glassBackground()
        .applyGlassToolbar()
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

#Preview {
    BookmarkView(selectedTab: Binding.constant(AppTab.bookmarks))
        .environmentObject(NavigationRouter())
}
