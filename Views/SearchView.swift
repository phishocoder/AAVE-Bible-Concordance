//
//  SearchView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/7/25.
//

import SwiftUI

struct SearchView: View {
    private static let resultLimit = 50
    private static let suggestions = [
        "John 3:16",
        "love",
        "faith",
        "peace",
        "forgiveness",
        "wisdom"
    ]

    @EnvironmentObject private var router: NavigationRouter
    @Binding var selectedTab: AppTab
    @State private var searchText = ""
    @State private var resultPage = SearchResultPage.empty(limit: resultLimit)
    @State private var isRefining = false
    @State private var error: BibleError?
    @State private var searchTask: Task<Void, Never>?
    @State private var activeQuery = ""

    @StateObject private var translationService = TranslationService.shared

    private let haptics = HapticManager.shared

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingSuggestions: [String] {
        guard !trimmedSearchText.isEmpty else { return Self.suggestions }
        return Self.suggestions.filter {
            $0.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }

    var body: some View {
        Group {
            if trimmedSearchText.isEmpty {
                initialSuggestions
            } else if let error, resultPage.results.isEmpty {
                errorState(error)
            } else if isRefining, resultPage.results.isEmpty {
                loadingState
            } else if resultPage.results.isEmpty {
                emptyState
            } else {
                resultsContent
            }
        }
        .padding(.horizontal, 16)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("Search")
        .searchable(
            text: $searchText,
            prompt: "Books, references, or words in AAVE Scripture."
        )
        .searchSuggestions {
            ForEach(matchingSuggestions, id: \.self) { suggestion in
                Label(suggestion, systemImage: suggestion == "John 3:16" ? "book" : "text.magnifyingglass")
                    .searchCompletion(suggestion)
            }
        }
        .onSubmit(of: .search) {
            submitSearch()
        }
        .onChange(of: searchText) { _, newValue in
            scheduleSearch(for: newValue)
        }
        .onDisappear {
            cancelScheduledSearch()
        }
    }

    private var initialSuggestions: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Search bundled AAVE Scripture")
                        .font(.headline)
                    Text(translationService.searchCoverageDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Enter a book, reference, or words from a verse.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .homeCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Try a search")
                        .font(.headline)

                    ForEach(Self.suggestions, id: \.self) { suggestion in
                        Button {
                            searchText = suggestion
                        } label: {
                            Label(
                                suggestion,
                                systemImage: suggestion == "John 3:16" ? "book" : "text.magnifyingglass"
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 4)
                    }
                }
                .homeCard()
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }

    private var loadingState: some View {
        ProgressView("Searching bundled AAVE Scripture…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No verses found",
            systemImage: "magnifyingglass",
            description: Text("Try different words or a reference like John 3:16.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ error: BibleError) -> some View {
        ContentUnavailableView {
            Label("Search unavailable", systemImage: "exclamationmark.magnifyingglass")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                submitSearch()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text(resultSummary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if isRefining {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityLabel("Refining search results")
                    }
                }
                .padding(.top, 12)

                if let error {
                    HStack {
                        Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Retry") {
                            submitSearch()
                        }
                        .font(.footnote.weight(.semibold))
                    }
                    .homeCard()
                }

                ForEach(resultPage.results) { result in
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
                                        .foregroundStyle(.yellow)
                                        .font(.system(size: 12))
                                        .accessibilityLabel("Commentary available")
                                }
                            }

                            if let preview = result.previewText {
                                Text(preview)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .lineLimit(3)
                            } else {
                                Text(result.kind == .book ? "Jump to book" : "Open chapter")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
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

    private var resultSummary: String {
        if resultPage.isLimited {
            return "Showing top \(resultPage.results.count) of \(resultPage.totalCount) results"
        }
        return resultPage.totalCount == 1 ? "1 result" : "\(resultPage.totalCount) results"
    }

    private func scheduleSearch(for text: String) {
        cancelScheduledSearch()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        activeQuery = trimmed

        guard !trimmed.isEmpty else {
            resultPage = .empty(limit: Self.resultLimit)
            isRefining = false
            error = nil
            return
        }

        isRefining = true
        error = nil
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(for: trimmed)
        }
    }

    private func submitSearch() {
        cancelScheduledSearch()
        let trimmed = trimmedSearchText
        activeQuery = trimmed
        guard !trimmed.isEmpty else { return }
        isRefining = true
        error = nil
        searchTask = Task {
            await performSearch(for: trimmed)
        }
    }

    @MainActor
    private func performSearch(for query: String) async {
        do {
            if !translationService.isLoaded {
                try await translationService.loadTranslations()
            }
            let page = try await translationService.searchAAVEScripture(
                query: query,
                limit: Self.resultLimit
            )

            guard activeQuery == query, !Task.isCancelled else { return }
            resultPage = page
            isRefining = false
        } catch {
            guard activeQuery == query, !Task.isCancelled else { return }
            self.error = error as? BibleError ?? .unknown
            isRefining = false
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

#Preview {
    NavigationStack {
        SearchView(selectedTab: Binding.constant(AppTab.bible))
            .environmentObject(NavigationRouter())
    }
}
