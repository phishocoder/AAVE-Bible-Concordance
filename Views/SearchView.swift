//
//  SearchView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Binding var selectedTab: AppTab
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var error: BibleError?
    @State private var searchTask: Task<Void, Never>?
    @State private var activeQuery: String = ""
    
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var verseManager = VerseManager.shared
    
    private let haptics = HapticManager.shared
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, isSearching: $isSearching) {
                cancelScheduledSearch()
                Task {
                    await performSearch(for: searchText)
                }
            }
            .onChange(of: searchText) { _, newValue in
                scheduleSearch(for: newValue)
            }
            
            if isSearching {
                ProgressView("Searching...")
                    .padding()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    "No verses found",
                    systemImage: "magnifyingglass",
                    description: Text("Try different keywords or another reference.")
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
    
    @MainActor
    private func performSearch(for rawQuery: String? = nil) async {
        let trimmedQuery = (rawQuery ?? searchText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            isSearching = false
            error = nil
            return
        }
        
        activeQuery = trimmedQuery
        isSearching = true
        error = nil
        
        do {
            let results = try await verseManager.searchVerses(
                trimmedQuery,
                translation: settings.preferredTranslation
            )
            
            guard activeQuery == trimmedQuery else { return }
            searchResults = results
            isSearching = false
        } catch {
            guard activeQuery == trimmedQuery else { return }
            self.error = error as? BibleError ?? .unknown
            searchResults = []
            isSearching = false
        }
    }
    
    private func scheduleSearch(for text: String) {
        searchTask?.cancel()
        
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching = false
            error = nil
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(for: trimmed)
        }
    }
    
    private func cancelScheduledSearch() {
        searchTask?.cancel()
        searchTask = nil
    }
    
    private func navigateToVerse(_ reference: VerseReference) {
        selectedTab = .bible
        router.resetAndGoTo(
            .bible(
                bookID: reference.book,
                chapter: reference.chapter,
                verse: reference.verse
            )
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
    SearchView(selectedTab: Binding.constant(AppTab.bible))
        .environmentObject(NavigationRouter())
}
