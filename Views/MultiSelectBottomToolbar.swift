//
//  MultiSelectBottomToolbar.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

struct MultiSelectBottomToolbar: View {
    @ObservedObject var viewModel: VerseListViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                Button(action: {
                    copyVersesToClipboard()
                }) {
                    VStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    shareVerses()
                }) {
                    VStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    highlightVerses()
                }) {
                    VStack {
                        Image(systemName: "highlighter")
                        Text("Highlight")
                            .font(.caption)
                    }
                }
                
                Button(action: {
                    bookmarkVerses()
                }) {
                    VStack {
                        Image(systemName: "bookmark")
                        Text("Bookmark")
                            .font(.caption)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
    }
    
    private func copyVersesToClipboard() {
        let text = viewModel.selectedVerses.map { "\($0.reference.book) \($0.reference.chapter):\($0.reference.verse) \($0.text)" }.joined(separator: "\n\n")
        UIPasteboard.general.string = text
        viewModel.isMultiSelectMode = false
        viewModel.selectedVerses = []
    }
    
    private func shareVerses() {
        let text = viewModel.selectedVerses.map { "\($0.reference.book) \($0.reference.chapter):\($0.reference.verse) \($0.text)" }.joined(separator: "\n\n")
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        
        viewModel.isMultiSelectMode = false
        viewModel.selectedVerses = []
    }
    
    private func highlightVerses() {
        // Show color picker or use default color
        let highlightManager = HighlightManager.shared
        for verse in viewModel.selectedVerses {
            highlightManager.addHighlight(verse.reference, color: .yellow)
        }
        viewModel.isMultiSelectMode = false
        viewModel.selectedVerses = []
    }
    
    private func bookmarkVerses() {
        // Replace BookmarkManager with Bookmarks
        let bookmarks = Bookmarks.shared
        for verse in viewModel.selectedVerses {
            if !bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
                bookmarks.addBookmark(
                    book: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse,
                    text: verse.text
                )
            }
        }
        viewModel.isMultiSelectMode = false
        viewModel.selectedVerses = []
    }
}
