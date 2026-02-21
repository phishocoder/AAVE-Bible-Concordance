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
    @State private var searchMode: SearchMode = .aave

    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var verseManager = VerseManager.shared

    private let haptics = HapticManager.shared

    var body: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                SearchBar(text: $searchText, isSearching: $isSearching) {
                    cancelScheduledSearch()
                    Task {
                        await performSearch(for: searchText)
                    }
                }
                .onChange(of: searchText) { _, newValue in
                    scheduleSearch(for: newValue)
                }

                Picker("Search Mode", selection: $searchMode) {
                    ForEach(SearchMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                
                Text(translationService.searchCoverageDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                if searchMode == .reference {
                    Text("Try: “John 3”, “John 3:16”, or “1 Corinthians 13”.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text("Tip: AAVE search is limited to available books.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .homeCard()

            if isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .homeCard()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    "No verses found",
                    systemImage: "magnifyingglass",
                    description: Text("Try different keywords or another reference.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(searchResults) { result in
                            Button {
                                haptics.impact(.light)
                                navigateToResult(result)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(result.displayTitle)
                                            .font(.headline)
                                        
                                        if result.kind == .verse,
                                           let chapter = result.chapter,
                                           let verse = result.verse,
                                           translationService.hasCommentary(
                                            for: result.book,
                                            chapter: chapter,
                                            verse: verse
                                           ) {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(.yellow)
                                                .font(.system(size: 12))
                                        }
                                    }

                                    if let preview = result.previewText {
                                        Text(preview)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(3)
                                    } else {
                                        Text(result.kind == .book ? "Jump to book" : "Open chapter")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .homeCard()
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .glassBackground()
        .applyGlassToolbar()
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

    private func navigateToResult(_ result: SearchResult) {
        let canonicalBook = BookNameNormalizer.canonicalBookName(result.book) ?? result.book
#if DEBUG
        assertCanonicalBook(canonicalBook, context: "SearchView.navigateToResult")
#endif
        // Request intent first; Bible tab applies this deep link when active.
        switch result.kind {
        case .book:
            router.requestDeepLink(.bookChapters(bookID: canonicalBook))

        case .chapter:
            router.requestDeepLink(
                .bible(
                    bookID: canonicalBook,
                    chapter: result.resolvedChapter,
                    verse: nil
                )
            )

        case .verse:
            guard let verse = result.resolvedVerse else { return }
            router.requestDeepLink(
                .bible(
                    bookID: canonicalBook,
                    chapter: result.resolvedChapter,
                    verse: verse
                )
            )
        }

        selectedTab = .bible
    }
}

private enum SearchMode: CaseIterable {
    case aave
    case reference

    var label: String {
        switch self {
        case .aave:
            return "AAVE"
        case .reference:
            return "Reference"
        }
    }
}

private struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search verses...", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSubmit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SearchView(selectedTab: Binding.constant(AppTab.bible))
        .environmentObject(NavigationRouter())
}
