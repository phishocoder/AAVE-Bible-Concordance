//
//  VerseDetailView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct VerseDetailView: View {
    let reference: VerseReference
    
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var userDataManager = UserDataManager.shared
    @ObservedObject private var bookmarks = Bookmarks.shared
    
    @State private var translations: (aave: String?, traditional: String?) = (nil, nil)
    @State private var commentary: String?
    @State private var error: BibleError?
    @State private var showingNotes = false
    @State private var showingCommentary = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Reference header
                Text("\(reference.book) \(reference.chapter):\(reference.verse)")
                    .font(.headline)
                    .padding(.top)
                
                // AAVE Translation
                if let aaveText = translations.aave {
                    TranslationCard(
                        title: "AAVE Translation",
                        text: aaveText,
                        fontSize: settings.fontSize,
                        isComingSoon: aaveText.contains("Coming Soon")
                    )
                }
                
                // Traditional Translation
                if let traditionalText = translations.traditional {
                    TranslationCard(
                        title: "NET Translation",
                        text: traditionalText,
                        fontSize: settings.fontSize
                    )
                }
                
                // Tools section
                HStack(spacing: 20) {
                    Button(action: handleBookmark) {
                        Image(systemName: bookmarks.isBookmarked(book: reference.book, chapter: reference.chapter, verse: reference.verse) ? "bookmark.fill" : "bookmark")
                            .font(.title2)
                    }
                    
                    Button(action: handleNotes) {
                        Image(systemName: "note.text")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingNotes) {
                        NotesView(reference: reference)
                    }
                    
                    Button(action: handleShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTranslations()
        }
        .alert("Error", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func loadTranslations() async {
        do {
            async let aaveText = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "AAVE"
            )
            
            async let traditionalText = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "NET"
            )
            
            translations = try await (aave: aaveText, traditional: traditionalText)
            
            commentary = translationService.getVerseCommentary(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse
            )
            
            userDataManager.addToHistory(reference)
        } catch {
            self.error = error as? BibleError
        }
    }
    
    private func handleBookmark() {
        if bookmarks.isBookmarked(book: reference.book, chapter: reference.chapter, verse: reference.verse) {
            if let bookmark = bookmarks.bookmarks.first(where: {
                $0.book == reference.book &&
                $0.chapter == reference.chapter &&
                $0.verse == reference.verse
            }) {
                bookmarks.removeBookmark(withId: bookmark.id)
            }
        } else {
            let text = translations.aave ?? translations.traditional ?? ""
            bookmarks.addBookmark(
                book: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                text: text
            )
        }
    }
    
    private func handleNotes() {
        showingNotes = true
    }
    
    private func handleShare() {
        var shareText = "\(reference.book) \(reference.chapter):\(reference.verse)\n\n"
        
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
}
