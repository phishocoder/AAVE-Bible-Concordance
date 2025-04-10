//
//  MultiVerseActionsOverlay.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import SwiftUI

struct MultiVerseActionsOverlay: View {
    let verses: [Verse]
    let onDismiss: () -> Void
    
    @StateObject private var bookmarks = Bookmarks.shared
    @StateObject private var userDataManager = UserDataManager.shared
    @StateObject private var haptics = HapticManager.shared
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Selected Verses")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Display verse references
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(verses, id: \.reference.id) { verse in
                        Text("\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse)")
                            .font(.subheadline)
                    }
                }
                .frame(maxHeight: 150)
            }
            
            Divider()
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    copyVersesToClipboard()
                    haptics.impact(.medium)
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    shareVerses()
                    haptics.impact(.medium)
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    bookmarkVerses()
                    haptics.notification(.success)
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "bookmark")
                        Text("Bookmark All")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    private func copyVersesToClipboard() {
        var text = ""
        
        for verse in verses {
            text += "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)\n\n"
        }
        
        UIPasteboard.general.string = text
    }
    
    private func shareVerses() {
        var text = ""
        
        for verse in verses {
            text += "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)\n\n"
        }
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func bookmarkVerses() {
        let bookmarks = Bookmarks.shared
        for verse in verses {
            if !bookmarks.isBookmarked(book: verse.reference.book, chapter: verse.reference.chapter, verse: verse.reference.verse) {
                bookmarks.addBookmark(
                    book: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse,
                    text: verse.text
                )
            }
        }
    }
}
