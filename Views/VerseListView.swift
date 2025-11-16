//
//  VerseListView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

// Add this helper struct to lazily load views
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

struct VerseListView: View {
    // Navigation parameters
    let book: String
    let chapter: Int
    let initialVerse: Int?
    
    // View model
    @StateObject private var viewModel: VerseListViewModel
    @StateObject private var settings = SettingsViewModel.shared
    
    // UI state
    @State private var showingBookPicker = false
    @State private var showTranslationPicker = false
    @State private var showMultiVerseActions = false
    @State private var showShareSheet = false
    @State private var shareText = ""
    
    private var backgroundColor: Color {
        // Your color logic here
        return Color(.systemBackground)
    }
    
    init(book: String, chapter: Int, initialVerse: Int? = nil) {
        self.book = book
        self.chapter = chapter
        self.initialVerse = initialVerse
        _viewModel = StateObject(wrappedValue: VerseListViewModel(book: book, chapter: chapter, initialVerse: initialVerse))
    }
    
    var body: some View {
        // Main content
        VerseListMainContent(
            viewModel: viewModel,
            settings: settings,
            showingBookPicker: $showingBookPicker,
            showTranslationPicker: $showTranslationPicker
        )
        .overlay {
            // Only show the commentary overlay when needed
            if viewModel.showCommentary, let reference = viewModel.commentaryReference {
                CommentaryOverlay(
                    verse: reference,
                    onDismiss: { viewModel.showCommentary = false }
                )
            }
        }
        
        
        
        .overlay(alignment: .bottom) {
            Group {
                // Only create and show the toolbar when needed
                if (viewModel.selectedVerse != nil || !viewModel.selectedVerses.isEmpty) {
                    LazyView(
                        UnifiedBottomToolbar(
                            viewModel: viewModel,
                            showShareSheet: $showShareSheet,
                            shareText: $shareText
                        )
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedVerse != nil || !viewModel.selectedVerses.isEmpty)
                }
            }
            .opacity(viewModel.isNavigating ? 0 : 1) // Extra layer of control to prevent flashing
        }

       
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
        .glassBackground()
        
        .onChange(of: viewModel.selectedVerses.count) { oldValue, newValue in
            showMultiVerseActions = newValue > 0
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowCommentary"))) { notification in
            if let reference = notification.userInfo?["reference"] as? VerseReference {
                viewModel.showCommentary = true
                viewModel.commentaryReference = reference
            }
        }
    }
}

// MARK: - Supporting Views

// Main content view
struct VerseListMainContent: View {
    @ObservedObject var viewModel: VerseListViewModel
    @ObservedObject var settings: SettingsViewModel
    @Binding var showingBookPicker: Bool
    @Binding var showTranslationPicker: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        mainContentView
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadVerses() }
            .onChange(of: settings.preferredTranslation) { oldValue, newValue in
                Task { await viewModel.loadVerses() }
            }
            .onChange(of: viewModel.currentBook) { oldValue, newValue in
                Task { await viewModel.loadVerses() }
            }
            .onChange(of: viewModel.currentChapter) { oldValue, newValue in
                Task { await viewModel.loadVerses() }
            }
            .id(viewModel.refreshID)
            .toolbar {
                if viewModel.isMultiSelectMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            viewModel.cancelMultiSelect()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                // Implement highlight action
                            }) {
                                Image(systemName: "highlighter")
                            }
                            
                            Button(action: {
                                // Implement bookmark action
                            }) {
                                Image(systemName: "bookmark")
                            }
                            
                            Button(action: {
                                // Implement share action
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingBookPicker) {
                bookPickerSheet
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("HighlightVerse"))) { notification in
                handleHighlightNotification(notification)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RefreshVerseHighlights"))) { _ in
                viewModel.refreshID = UUID() // Force refresh the view
            }
    }
    
    // Break down the body into smaller computed properties
    private var mainContentView: some View {
        VStack(spacing: 20) {
            ChapterNavigationHeader(
                book: viewModel.currentBook,
                chapter: viewModel.currentChapter,
                translation: settings.preferredTranslation,
                onPrevious: viewModel.navigateToPreviousChapter,
                onNext: viewModel.navigateToNextChapter,
                onBookTap: { showingBookPicker = true },
                onTranslationTap: { showTranslationPicker.toggle() }
            )
            .padding(.horizontal, 24)
            .padding(.top, 24)

            if showTranslationPicker {
                translationPickerCard
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1)
            }

            if viewModel.isLoading {
                ProgressView("Loading verses...")
                    .padding()
                    .glassCard()
                    .padding(.horizontal, 24)
            } else {
                VerseListContent(viewModel: viewModel)
            }
        }
    }
    
    private var bookPickerSheet: some View {
        BookChapterPickerView(
            selectedBook: $viewModel.currentBook,
            selectedChapter: $viewModel.currentChapter,
            selectedVerse: $viewModel.highlightedVerse,
            onSelect: {
                showingBookPicker = false
                
                // If a verse was selected, scroll to it
                if let verse = viewModel.highlightedVerse {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        NotificationCenter.default.post(
                            name: Notification.Name("HighlightVerse"),
                            object: nil,
                            userInfo: [
                                "book": viewModel.currentBook,
                                "chapter": viewModel.currentChapter,
                                "verse": verse
                            ]
                        )
                    }
                }
            }
        )
    }
    
    // Handle highlight notification
    private func handleHighlightNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let book = userInfo["book"] as? String,
              let chapter = userInfo["chapter"] as? Int,
              let verse = userInfo["verse"] as? Int,
              book == viewModel.currentBook && chapter == viewModel.currentChapter else {
            return
        }
        
        viewModel.highlightedVerse = verse
    }

    private var translationPickerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(["AAVE", "NET", "KJV"], id: \.self) { translation in
                Button(action: {
                    settings.preferredTranslation = translation
                    showTranslationPicker = false
                }) {
                    HStack {
                        Text(translation)
                            .foregroundColor(.primary)

                        if settings.preferredTranslation == translation {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.12) : Color.white.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.2 : 0.3), lineWidth: 1)
                )
        )
        .shadow(radius: 10)
    }
}

// MARK: - Verse List Content
struct VerseListContent: View {
    @ObservedObject var viewModel: VerseListViewModel
    @ObservedObject private var translationService = TranslationService.shared
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.verses, id: \.reference.id) { verse in
                        VerseRow(
                            verse: verse,
                            isMultiSelectMode: viewModel.isMultiSelectMode,
                            isSelected: viewModel.isVerseSelected(verse),
                            hasCommentary: translationService.hasCommentary(
                                for: verse.reference.book,
                                chapter: verse.reference.chapter,
                                verse: verse.reference.verse
                            ),
                            onTap: { viewModel.handleVerseTap(verse) },
                            onLongPress: { viewModel.handleVerseLongPress(verse) },
                            onCommentaryTap: {
                                viewModel.showCommentary = true
                                viewModel.commentaryReference = verse.reference
                            }
                        )
                        // Use a more stable ID that doesn't trigger full redraws
                        .id(scrollID(for: verse.reference))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        // Only trigger navigation if the drag is primarily horizontal
                        let horizontalAmount = abs(value.translation.width)
                        let verticalAmount = abs(value.translation.height)
                        
                        if horizontalAmount > verticalAmount && horizontalAmount > 50 {
                            if value.translation.width > 0 {
                                viewModel.navigateToPreviousChapter()
                            } else if value.translation.width < 0 {
                                viewModel.navigateToNextChapter()
                            }
                        }
                    }
            )
            .onChange(of: viewModel.highlightedVerse) { _, verse in
                guard let verse else { return }
                focus(on: verse, proxy: proxy, animated: true)
            }
            .onChange(of: viewModel.verses) { _, _ in
                guard let verse = viewModel.highlightedVerse else { return }
                focus(on: verse, proxy: proxy, animated: false)
            }
            .onAppear {
                if let verse = viewModel.highlightedVerse {
                    focus(on: verse, proxy: proxy, animated: false)
                }
            }
        }
    }
    
    private func focus(on verseNumber: Int, proxy: ScrollViewProxy, animated: Bool) {
        let id = scrollID(forVerse: verseNumber)
        let scrollAction = {
            proxy.scrollTo(id, anchor: .center)
        }
        
        if animated {
            withAnimation(.easeInOut) {
                scrollAction()
            }
        } else {
            scrollAction()
        }
        
        if let selected = viewModel.verses.first(where: {
            $0.reference.book == viewModel.currentBook &&
            $0.reference.chapter == viewModel.currentChapter &&
            $0.reference.verse == verseNumber
        }) {
            viewModel.selectedVerse = selected
            viewModel.isMultiSelectMode = false
        }
    }
    
    private func scrollID(for reference: VerseReference) -> String {
        "verse-\(reference.key)"
    }
    
    private func scrollID(forVerse verse: Int) -> String {
        "verse-\(viewModel.currentBook)_\(viewModel.currentChapter)_\(verse)"
    }
}

// MARK: - Verse Context Menu
struct VerseContextMenu: View {
    let verse: Verse
    @ObservedObject private var bookmarks = Bookmarks.shared
    @ObservedObject private var highlightManager = HighlightManager.shared
    
    var body: some View {
        Button(action: {
            UIPasteboard.general.string = "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)"
        }) {
            Label("Copy", systemImage: "doc.on.doc")
        }
        
        Button(action: {
            toggleBookmark()
        }) {
            Label(
                bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) ? "Remove Bookmark" : "Bookmark",
                systemImage: bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) ? "bookmark.fill" : "bookmark"
            )
        }
        
        Menu("Highlight") {
            Button(action: { highlightManager.addHighlight(verse.reference, color: .yellow.opacity(0.3)) }) {
                Label("Yellow", systemImage: "circle.fill")
                    .foregroundColor(.yellow)
            }
            
            Button(action: { highlightManager.addHighlight(verse.reference, color: .green.opacity(0.3)) }) {
                Label("Green", systemImage: "circle.fill")
                    .foregroundColor(.green)
            }
            
            Button(action: { highlightManager.addHighlight(verse.reference, color: .blue.opacity(0.3)) }) {
                Label("Blue", systemImage: "circle.fill")
                    .foregroundColor(.blue)
            }
            
            Button(action: { highlightManager.addHighlight(verse.reference, color: .pink.opacity(0.3)) }) {
                Label("Pink", systemImage: "circle.fill")
                    .foregroundColor(.pink)
            }
            
            if highlightManager.getHighlightColor(for: verse.reference) != nil {
                Button(role: .destructive, action: { highlightManager.removeHighlight(verse.reference) }) {
                    Label("Remove Highlight", systemImage: "xmark.circle")
                }
            }
        }
    }
    
    private func toggleBookmark() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        if bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
            if let bookmark = bookmarks.bookmarks.first(where: {
                $0.book == verse.reference.book &&
                $0.chapter == verse.reference.chapter &&
                $0.verse == verse.reference.verse
            }) {
                bookmarks.removeBookmark(withId: bookmark.id)
            }
        } else {
            bookmarks.addBookmark(
                book: verse.reference.book,
                chapter: verse.reference.chapter,
                verse: verse.reference.verse,
                text: verse.text
            )
        }
    }
}
