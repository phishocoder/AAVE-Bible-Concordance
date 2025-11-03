//
//  VerseActionsOverlay.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import SwiftUI

struct VerseActionsOverlayView: View {
    @ObservedObject var viewModel: VerseListViewModel
    
    @State private var showingTranslations = false
    @State private var showingNotes = false
    @State private var showingHighlightPicker = false
    @State private var showingShareSheet = false
    @ObservedObject private var translationService = TranslationService.shared
    @ObservedObject private var userDataManager = UserDataManager.shared
    @ObservedObject private var highlightManager = HighlightManager.shared
    private let haptics = HapticManager.shared
    
    var body: some View {
        if let verse = viewModel.selectedVerse {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.showVerseActions = false
                    }
                
                VStack(spacing: 16) {
                    // Header with verse reference and close button
                    HStack {
                        Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { viewModel.showVerseActions = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Verse text
                    Text(verse.text)
                        .padding(.vertical, 8)
                    
                    // Action buttons in a scrollable horizontal layout
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ActionButton(
                                icon: "book",
                                label: "Translations",
                                action: showTranslations
                            )
                            
                            ActionButton(
                                icon: "highlighter",
                                label: "Highlight",
                                action: showHighlightPicker
                            )
                            
                            ActionButton(
                                icon: Bookmarks.shared.isBookmarked(book: verse.reference.book,
                                                                    chapter: verse.reference.chapter,
                                                                    verse: verse.reference.verse) ? "bookmark.fill" : "bookmark",
                                label: Bookmarks.shared.isBookmarked(book: verse.reference.book,
                                                                     chapter: verse.reference.chapter,
                                                                     verse: verse.reference.verse) ? "Bookmarked" : "Bookmark",
                                action: { toggleBookmark(verse) }
                            )
                            
                            ActionButton(
                                icon: "note.text",
                                label: "Note",
                                action: addNote
                            )
                            
                            ActionButton(
                                icon: "doc.on.doc",
                                label: "Copy",
                                action: { copyVerse(verse) }
                            )
                            
                            ActionButton(
                                icon: "square.and.arrow.up",
                                label: "Share",
                                action: { shareVerse(verse) }
                            )
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding()
                .sheet(isPresented: $showingTranslations) {
                    NavigationView {
                        if let verse = viewModel.selectedVerse {
                            TranslationsView(verse: verse)
                        }
                    }
                }
                .sheet(isPresented: $showingNotes) {
                    NavigationView {
                        if let verse = viewModel.selectedVerse {
                            NotesView(reference: verse.reference)
                        }
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let verse = viewModel.selectedVerse {
                        ShareSheet(items: [createShareText(verse)])
                    }
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
            }
        }
    }
    
    // Reuse the same functions from VerseActionsSheet
    func showTranslations() {
        haptics.impact(.light)
        showingTranslations = true
    }
    
    func showHighlightPicker() {
        haptics.impact(.light)
        showingHighlightPicker = true
    }
    
    func highlightVerse(with color: Color) {
        haptics.impact(.light)
        if let verse = viewModel.selectedVerse {
            // Get the verse text to store with highlight
            let verseText = verse.text
            
            // Use withAnimation(nil) to prevent scroll position reset
            withAnimation(nil) {
                highlightManager.addHighlight(verse.reference, color: color, text: verseText)
            }
            
            // Post notification to refresh only highlights without scrolling
            NotificationCenter.default.post(
                name: Notification.Name("RefreshVerseHighlights"),
                object: nil
            )
        }
    }
    
    func removeHighlight() {
        haptics.impact(.light)
        if let verse = viewModel.selectedVerse {
            highlightManager.removeHighlight(verse.reference)
        }
    }
    
    func toggleBookmark(_ verse: Verse) {
        haptics.impact(.light)
        
        // Use the Bookmarks singleton
        let bookmarks = Bookmarks.shared
        
        if bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
            // Find the bookmark to remove
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
    
    func addNote() {
        haptics.impact(.light)
        showingNotes = true
    }
    
    func copyVerse(_ verse: Verse) {
        haptics.impact(.light)
        UIPasteboard.general.string = "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)"
    }
    
    func shareVerse(_ verse: Verse) {
        haptics.impact(.light)
        showingShareSheet = true
    }
    
    func createShareText(_ verse: Verse) -> String {
        return "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)"
    }
}

// Add the ActionButton struct here
struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.primary)
        }
    }
}
