import SwiftUI

struct VerseDetailSheet: View {
    let verses: [Verse]
    let initialVerseIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var userDataManager = UserDataManager.shared
    private let haptics = HapticManager.shared
    
    @State private var currentVerseIndex: Int
    @State private var translations: (aave: String?, traditional: String?) = (nil, nil)
    @State private var hasCommentary: Bool = false
    @State private var showingCommentary = false
    @State private var showingNotes = false
    @State private var showingHighlightPicker = false
    
    init(verses: [Verse], initialVerseIndex: Int = 0) {
        self.verses = verses
        self.initialVerseIndex = initialVerseIndex
        self._currentVerseIndex = State(initialValue: initialVerseIndex)
    }
    
    private var currentVerse: Verse {
        verses[currentVerseIndex]
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("\(currentVerse.reference.book) \(currentVerse.reference.chapter):\(currentVerse.reference.verse)")
                            .font(.headline)
                        Spacer()
                        navigationControls
                    }
                    .padding(.horizontal)
                    
                    if let aaveText = translations.aave {
                        TranslationCard(
                            title: "AAVE Translation",
                            text: aaveText,
                            fontSize: settings.fontSize
                        )
                    }
                    
                    if let traditionalText = translations.traditional {
                        TranslationCard(
                            title: "NET Translation",
                            text: traditionalText,
                            fontSize: settings.fontSize
                        )
                    }
                    
                    if hasCommentary {
                        commentaryButton
                    }
                    
                    toolsSection
                    
                    if currentVerseIndex == verses.count - 1 {
                        nextChapterButton
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNotes) {
                NotesView(reference: currentVerse.reference)
            }
            .actionSheet(isPresented: $showingHighlightPicker) {
                ActionSheet(
                    title: Text("Choose Highlight Color"),
                    buttons: [
                        .default(Text("Yellow")) { highlightVerse(with: .yellow) },
                        .default(Text("Green")) { highlightVerse(with: .green) },
                        .default(Text("Blue")) { highlightVerse(with: .blue) },
                        .default(Text("Pink")) { highlightVerse(with: .pink) },
                        .default(Text("Purple")) { highlightVerse(with: .purple) },
                        .destructive(Text("Remove Highlight")) { removeHighlight() },
                        .cancel()
                    ]
                )
            }
            .onChange(of: currentVerseIndex) { oldValue, newValue in
                Task {
                    await loadTranslations()
                }
            }
            .task {
                await loadTranslations()
            }
            // Overlay for commentary
            .overlay {
                if showingCommentary {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showingCommentary = false
                            }
                        
                        VStack {
                            CommentaryOverlay(
                                verse: currentVerse.reference,
                                onDismiss: { showingCommentary = false }
                            )
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(radius: 10)
                        }
                        .padding()
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showingCommentary)
                }
            }
        }
    }
    
    private var navigationControls: some View {
        HStack(spacing: 20) {
            Button(action: previousVerse) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
            }
            .disabled(currentVerseIndex == 0)
            
            Button(action: nextVerse) {
                Image(systemName: "chevron.right")
                    .imageScale(.large)
            }
            .disabled(currentVerseIndex == verses.count - 1)
        }
    }
    
    private var commentaryButton: some View {
        Button(action: {
            haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
            showingCommentary = true
        }) {
            HStack {
                Image(systemName: "text.book.closed")
                Text("View Commentary")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    private var toolsSection: some View {
        VStack(spacing: 12) {
            Text("Tools")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                ToolButton(
                    icon: "note.text",
                    label: "Notes",
                    action: handleNotes
                )
                
                ToolButton(
                    icon: Bookmarks.shared.isBookmarked(book: currentVerse.reference.book,
                                                       chapter: currentVerse.reference.chapter,
                                                       verse: currentVerse.reference.verse) ? "bookmark.fill" : "bookmark",
                    label: "Bookmark",
                    action: handleBookmark,
                    isActive: Bookmarks.shared.isBookmarked(book: currentVerse.reference.book,
                                                           chapter: currentVerse.reference.chapter,
                                                           verse: currentVerse.reference.verse)
                )
                
                ToolButton(
                    icon: "highlighter",
                    label: "Highlight",
                    action: handleHighlight
                )
                
                ToolButton(
                    icon: "square.and.arrow.up",
                    label: "Share",
                    action: handleShare
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var nextChapterButton: some View {
        Button(action: {
            // Handle next chapter navigation
        }) {
            Text("Next Chapter")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func nextVerse() {
        if currentVerseIndex < verses.count - 1 {
            haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
            currentVerseIndex += 1
        }
    }
    
    private func previousVerse() {
        if currentVerseIndex > 0 {
            haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
            currentVerseIndex -= 1
        }
    }
    
    private func loadTranslations() async {
        do {
            let ref = currentVerse.reference
            
            async let aaveText = translationService.getVerseTranslation(
                for: ref.book,
                chapter: ref.chapter,
                verse: ref.verse,
                translation: "AAVE"
            )
            
            async let traditionalText = translationService.getVerseTranslation(
                for: ref.book,
                chapter: ref.chapter,
                verse: ref.verse,
                translation: "NET"
            )
            
            translations = try await (aave: aaveText, traditional: traditionalText)
            
            hasCommentary = translationService.hasCommentary(
                for: ref.book,
                chapter: ref.chapter,
                verse: ref.verse
            )
            
            userDataManager.addToHistory(currentVerse.reference)
        } catch {
            print("Error loading translations: \(error)")
        }
    }
    
    private func handleNotes() {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        showingNotes = true
    }
    
    private func handleBookmark() {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        let bookmarks = Bookmarks.shared
        if bookmarks.isBookmarked(book: currentVerse.reference.book,
                                 chapter: currentVerse.reference.chapter,
                                 verse: currentVerse.reference.verse) {
            if let bookmark = bookmarks.bookmarks.first(where: {
                $0.book == currentVerse.reference.book &&
                $0.chapter == currentVerse.reference.chapter &&
                $0.verse == currentVerse.reference.verse
            }) {
                bookmarks.removeBookmark(withId: bookmark.id)
            }
        } else {
            bookmarks.addBookmark(
                book: currentVerse.reference.book,
                chapter: currentVerse.reference.chapter,
                verse: currentVerse.reference.verse,
                text: currentVerse.text
            )
        }
    }
    
    private func handleHighlight() {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        showingHighlightPicker = true
    }
    
    private func handleShare() {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        
        var shareText = "\(currentVerse.reference.book) \(currentVerse.reference.chapter):\(currentVerse.reference.verse)\n\n"
        
        if let aaveText = translations.aave, !aaveText.contains("Coming Soon") {
            shareText += "AAVE: \(aaveText)\n\n"
        }
        
        if let traditionalText = translations.traditional {
            shareText += "NET: \(traditionalText)"
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func highlightVerse(with color: Color) {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        HighlightManager.shared.addHighlight(currentVerse.reference, color: color)
    }
    
    private func removeHighlight() {
        haptics.impact(UIImpactFeedbackGenerator.FeedbackStyle.light)
        HighlightManager.shared.removeHighlight(currentVerse.reference)
    }
}
