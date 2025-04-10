//
//  CommentaryOverlay.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import SwiftUI

import SwiftUI

struct CommentaryOverlay: View {
    let verse: VerseReference
    let onDismiss: () -> Void
    
    @ObservedObject private var translationService = TranslationService.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Commentary")
                        .font(.headline)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                Text("\(verse.book) \(verse.chapter):\(verse.verse)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let commentary = translationService.getVerseCommentary(
                    for: verse.book,
                    chapter: verse.chapter,
                    verse: verse.verse
                ) {
                    Text(commentary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No commentary available for this verse.")
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding()
        }
    }
}

struct CommentaryOverlayView: View {
    let verse: Verse
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack {
                CommentaryOverlay(
                    verse: verse.reference,
                    onDismiss: onDismiss
                )
                .padding()
            }
            .padding()
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: true)
    }
}
