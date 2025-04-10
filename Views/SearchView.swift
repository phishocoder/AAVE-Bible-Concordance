//
//  SearchView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var error: BibleError?
    
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var verseManager = VerseManager.shared
    
    private let haptics = HapticManager.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText, isSearching: $isSearching) {
                    Task {
                        await performSearch()
                    }
                }
                
                if isSearching {
                    ProgressView("Searching...")
                        .padding()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try different keywords")
                    )
                } else {
                    List(searchResults) { result in
                        Button {
                            haptics.impact(.light)
                            navigateToVerse(result.reference)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(result.reference.book) \(result.reference.chapter):\(result.reference.verse)")
                                        .font(.headline)
                                    
                                    if translationService.hasCommentary(
                                        for: result.reference.book,
                                        chapter: result.reference.chapter,
                                        verse: result.reference.verse
                                    ) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 12))
                                    }
                                }
                                
                                Text(result.text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        error = nil
        
        do {
            searchResults = try await verseManager.searchVerses(
                searchText,
                translation: settings.preferredTranslation
            )
        } catch {
            self.error = error as? BibleError ?? .unknown
        }
        
        isSearching = false
    }
    
    private func navigateToVerse(_ reference: VerseReference) {
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToVerse"),
            object: nil,
            userInfo: [
                "book": reference.book,
                "chapter": reference.chapter,
                "verse": reference.verse,
                "showDetail": true
            ]
        )
    }
}

private struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search verses...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.search)
                .onSubmit(onSubmit)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSubmit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    SearchView()
}
