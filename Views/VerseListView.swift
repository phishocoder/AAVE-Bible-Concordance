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
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showingVerseActionSheet = false
    @State private var selectedActionVerse: Verse?
    @State private var showingHighlightPalette = false
    @State private var noteReference: VerseReference?
    @State private var compareReference: VerseReference?
    @State private var showingVerseImageSheet = false
    @AppStorage("hasSeenVerseActionsLongPressHint") private var hasSeenLongPressHint = false
    @StateObject private var bookmarks = Bookmarks.shared
    @StateObject private var highlightManager = HighlightManager.shared
    private let haptics = HapticManager.shared
    
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
            showTranslationPicker: $showTranslationPicker,
            onVerseLongPress: handleVerseLongPress
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
        .overlay(alignment: .bottom) {
            ToastView(message: toastMessage, isShowing: $showToast)
                .padding(.bottom, viewModel.selectedVerse != nil || !viewModel.selectedVerses.isEmpty ? 96 : 20)
        }

       
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [shareText])
        }
        .sheet(isPresented: $showingVerseActionSheet, onDismiss: {
            selectedActionVerse = nil
            showingHighlightPalette = false
        }) {
            if let verse = selectedActionVerse {
                VerseActionSheetView(
                    verse: verse,
                    translationLabel: settings.preferredTranslation,
                    isBookmarked: isBookmarked(verse),
                    isHighlighted: highlightManager.isHighlighted(verse.reference),
                    currentHighlightColor: highlightManager.getHighlightColor(for: verse.reference),
                    showsHighlightPalette: showingHighlightPalette,
                    onAction: { action in
                        handleVerseAction(action, verse: verse)
                    },
                    onHighlightColor: { color in
                        highlightManager.addHighlight(verse.reference, color: color)
                        haptics.selection()
                        showSavedToast()
                        showingVerseActionSheet = false
                    },
                    onRemoveHighlight: {
                        highlightManager.removeHighlight(verse.reference)
                        haptics.selection()
                        showSavedToast(message: "Removed")
                        showingVerseActionSheet = false
                    },
                    onCancel: { showingVerseActionSheet = false }
                )
                .presentationDetents([.height(220), .medium])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(item: $noteReference) { reference in
            NotesView(reference: reference)
        }
        .sheet(item: $compareReference) { reference in
            CompareTranslationsSheet(reference: reference)
        }
        .sheet(isPresented: $showingVerseImageSheet) {
            if let verse = selectedActionVerse {
                VerseImageCreatorView(verse: verse)
            }
        }
        .glassBackground()
        .task(id: "\(book)-\(chapter)-\(initialVerse ?? -1)") {
            await viewModel.applyDeepLink(book: book, chapter: chapter, verse: initialVerse)
        }
        
        .onChange(of: viewModel.selectedVerses.count) { oldValue, newValue in
            showMultiVerseActions = newValue > 0
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowCommentary"))) { notification in
            if let reference = notification.userInfo?["reference"] as? VerseReference {
                viewModel.showCommentary = true
                viewModel.commentaryReference = reference
            }
        }
        .onAppear {
            NotificationManager.shared.markBibleReaderOpened()
        }
        .onAppear {
            guard !hasSeenLongPressHint else { return }
            toastMessage = "Tip: long-press a verse to open actions."
            showToast = true
            hasSeenLongPressHint = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                showToast = false
            }
        }
    }

    private func handleVerseLongPress(_ verse: Verse) {
        // Ensure old multi-select toolbar does not conflict with the new action sheet.
        viewModel.selectedVerse = nil
        viewModel.selectedVerses = []
        viewModel.isMultiSelectMode = false
        selectedActionVerse = verse
        showingHighlightPalette = false
        showingVerseActionSheet = true
    }

    private func handleVerseAction(_ action: VerseActionSheetAction, verse: Verse) {
        switch action {
        case .highlight:
            showingHighlightPalette.toggle()
        case .bookmark:
            let nowBookmarked = toggleBookmark(for: verse)
            if nowBookmarked {
                showSavedToast()
            }
            showingVerseActionSheet = false
        case .note:
            showingVerseActionSheet = false
            noteReference = verse.reference
        case .copy:
            UIPasteboard.general.string = "\(verse.reference.displayString) - \(verse.text)"
            showSavedToast()
            showingVerseActionSheet = false
        case .share:
            shareText = "\"\(verse.text)\" - \(verse.reference.displayString) (\(settings.preferredTranslation))"
            showingVerseActionSheet = false
            showShareSheet = true
            AchievementService.shared.recordShare()
        case .verseImage:
            showingVerseActionSheet = false
            showingVerseImageSheet = true
        case .compareTranslation:
            showingVerseActionSheet = false
            compareReference = verse.reference
        }
    }

    private func isBookmarked(_ verse: Verse) -> Bool {
        bookmarks.isBookmarked(
            book: verse.reference.book,
            chapter: verse.reference.chapter,
            verse: verse.reference.verse
        )
    }

    private func toggleBookmark(for verse: Verse) -> Bool {
        if let bookmark = bookmarks.bookmarks.first(where: {
            $0.book == verse.reference.book &&
            $0.chapter == verse.reference.chapter &&
            $0.verse == verse.reference.verse
        }) {
            bookmarks.removeBookmark(withId: bookmark.id)
            return false
        }

        bookmarks.addBookmark(
            book: verse.reference.book,
            chapter: verse.reference.chapter,
            verse: verse.reference.verse,
            text: verse.text
        )
        return true
    }

    private func showSavedToast(message: String = "Saved") {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showToast = false
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
    let onVerseLongPress: (Verse) -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        mainContentView
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: settings.preferredTranslation) { oldValue, newValue in
                Task { await viewModel.loadVerses() }
            }
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
                VerseListContent(
                    viewModel: viewModel,
                    onVerseLongPress: onVerseLongPress
                )
            }
        }
    }
    
    private var bookPickerSheet: some View {
        BookChapterPickerView(
            selectedBook: $viewModel.currentBook,
            selectedChapter: $viewModel.currentChapter,
            selectedVerse: $viewModel.highlightedVerse,
            onSelect: {
                let selectedBook = viewModel.currentBook
                let selectedChapter = viewModel.currentChapter
                let selectedVerse = viewModel.highlightedVerse
                showingBookPicker = false

                Task {
                    // Route picker jumps through the same deep-link path so header and content stay in sync.
                    await viewModel.applyDeepLink(
                        book: selectedBook,
                        chapter: selectedChapter,
                        verse: selectedVerse
                    )

                    // If a verse was selected, scroll to it after chapter content reloads.
                    if let verse = selectedVerse {
                        NotificationCenter.default.post(
                            name: Notification.Name("HighlightVerse"),
                            object: nil,
                            userInfo: [
                                "book": selectedBook,
                                "chapter": selectedChapter,
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
    let onVerseLongPress: (Verse) -> Void
    @ObservedObject private var translationService = TranslationService.shared
    @State private var shouldScrollToTop = false
    @State private var isClearingFocus = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.verses, id: \.reference.id) { verse in
                        VerseRow(
                            verse: verse,
                            isMultiSelectMode: viewModel.isMultiSelectMode,
                            isSelected: viewModel.isVerseSelected(verse),
                            isFocused: verse.reference.id == viewModel.focusedVerseID,
                            hasCommentary: translationService.hasCommentary(
                                for: verse.reference.book,
                                chapter: verse.reference.chapter,
                                verse: verse.reference.verse
                            ),
                            onTap: { viewModel.handleVerseTap(verse) },
                            onLongPress: { onVerseLongPress(verse) },
                            onCommentaryTap: {
                                viewModel.showCommentary = true
                                viewModel.commentaryReference = verse.reference
                            }
                        )
                        // Use a more stable ID that doesn't trigger full redraws
                        .id(scrollID(for: verse.reference))
                        .onAppear {
                            // Track the last visible verse to restore position on relaunch.
                            viewModel.markLastVisibleVerse(verse.reference.verse)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        // Require a clear, intentional horizontal swipe that beats vertical movement.
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        let horizontalMagnitude = abs(horizontal)
                        let verticalMagnitude = abs(vertical)
                        let dominanceRatio: CGFloat = 1.25
                        let minTravel: CGFloat = 80

                        guard horizontalMagnitude > minTravel,
                              horizontalMagnitude > verticalMagnitude * dominanceRatio else { return }

                        if horizontal < 0 {
                            viewModel.navigateToNextChapter()
                        } else {
                            viewModel.navigateToPreviousChapter()
                        }
                    }
            )
            .onChange(of: viewModel.currentBook) { _, _ in
                // Chapter context changed; reset to verse 1 once new content is ready.
                shouldScrollToTop = true
                if viewModel.pendingFocusReference == nil {
                    viewModel.focusedVerseID = nil
                }
            }
            .onChange(of: viewModel.currentChapter) { _, _ in
                // Chapter context changed; reset to verse 1 once new content is ready.
                shouldScrollToTop = true
                if viewModel.pendingFocusReference == nil {
                    viewModel.focusedVerseID = nil
                }
            }
            .onChange(of: viewModel.highlightedVerse) { _, verse in
                guard let verse else { return }
                shouldScrollToTop = false
                if viewModel.verses.contains(where: { $0.reference.id == scrollID(forVerse: verse) }) {
                    focus(on: verse, proxy: proxy, animated: true)
                } else {
                    requestFocus(on: verse)
                }
            }
            .onChange(of: viewModel.verses) { _, _ in
                if let ref = viewModel.pendingFocusReference,
                   !viewModel.verses.isEmpty,
                   viewModel.verses.contains(where: { $0.reference.id == ref.id }) {
                    shouldScrollToTop = false
                    focus(on: ref, proxy: proxy, animated: true)
                } else if let verse = viewModel.highlightedVerse,
                          viewModel.verses.contains(where: { $0.reference.id == scrollID(forVerse: verse) }) {
                    shouldScrollToTop = false
                    focus(on: verse, proxy: proxy, animated: false)
                } else if shouldScrollToTop,
                          viewModel.verses.contains(where: { $0.reference.id == scrollID(forVerse: 1) }) {
                    focus(on: 1, proxy: proxy, animated: false)
                    shouldScrollToTop = false
                }
            }
            .onAppear {
                if let verse = viewModel.highlightedVerse,
                   viewModel.verses.contains(where: { $0.reference.id == scrollID(forVerse: verse) }) {
                    focus(on: verse, proxy: proxy, animated: false)
                } else if shouldScrollToTop,
                          viewModel.verses.contains(where: { $0.reference.id == scrollID(forVerse: 1) }) {
                    focus(on: 1, proxy: proxy, animated: false)
                    shouldScrollToTop = false
                }
            }
        }
    }
    
    private func focus(on verseNumber: Int, proxy: ScrollViewProxy, animated: Bool) {
        let id = scrollID(forVerse: verseNumber)
        guard viewModel.verses.contains(where: { $0.reference.id == id }) else { return }
        // Defer until the next run loop so the verse row exists in the layout.
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeInOut) {
                    proxy.scrollTo(id, anchor: .center)
                }
            } else {
                proxy.scrollTo(id, anchor: .center)
            }
            viewModel.pendingFocusReference = nil
            viewModel.focusedVerseID = id
            clearFocusHighlightIfNeeded()
        }
    }

    private func focus(on reference: VerseReference, proxy: ScrollViewProxy, animated: Bool) {
        let id = scrollID(for: reference)
        guard viewModel.verses.contains(where: { $0.reference.id == id }) else { return }
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeInOut) {
                    proxy.scrollTo(id, anchor: .center)
                }
            } else {
                proxy.scrollTo(id, anchor: .center)
            }
            viewModel.pendingFocusReference = nil
            viewModel.focusedVerseID = id
            clearFocusHighlightIfNeeded()
        }
    }

    private func scrollID(for reference: VerseReference) -> String {
        reference.id
    }
    
    private func scrollID(forVerse verse: Int) -> String {
        VerseReference(book: viewModel.currentBook, chapter: viewModel.currentChapter, verse: verse).id
    }

    private func requestFocus(on verse: Int) {
        let ref = VerseReference(book: viewModel.currentBook, chapter: viewModel.currentChapter, verse: verse)
        viewModel.pendingFocusReference = ref
        viewModel.focusedVerseID = ref.id
    }

    private func clearFocusHighlightIfNeeded() {
        guard !isClearingFocus else { return }
        isClearingFocus = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            viewModel.focusedVerseID = nil
            isClearingFocus = false
        }
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

// Simple toast view for in-app hints.
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        if isShowing {
            Text(message)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(12)
                .shadow(radius: 3)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: isShowing)
        }
    }
}
