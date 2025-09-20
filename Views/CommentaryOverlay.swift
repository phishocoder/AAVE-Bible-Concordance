//
//  CommentaryOverlay.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/15/25.
//

import SwiftUI

struct CommentaryOverlay: View {
    let verse: VerseReference
    let onDismiss: () -> Void
    
    @ObservedObject private var translationService = TranslationService.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Real Talk Commentary")
                            .font(.headline)
                        Text("\(verse.book) \(verse.chapter):\(verse.verse)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Divider()

                Group {
                    if let commentary = translationService.getVerseCommentary(
                        for: verse.book,
                        chapter: verse.chapter,
                        verse: verse.verse
                    ) {
                        Text(commentary)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text("No commentary available for this verse.")
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .glassCard()
            .padding(.horizontal, 24)
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
                .onTapGesture(perform: onDismiss)

            CommentaryOverlay(
                verse: verse.reference,
                onDismiss: onDismiss
            )
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: true)
    }
}
