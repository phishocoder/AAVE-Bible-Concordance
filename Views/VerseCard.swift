//
//  VerseCard.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

struct VerseCard: View {
    let verse: VerseItem
    @Binding var selectedVerse: VerseItem?

    @State private var showingCommentary = false
    @State private var hasCommentary = false

    @ObservedObject private var userDataManager = UserDataManager.shared
    @ObservedObject private var translationService = TranslationService.shared
    @ObservedObject private var settings = SettingsViewModel.shared
    @ObservedObject private var highlightManager = HighlightManager.shared

    private let haptics = HapticManager.shared

    var body: some View {
        Button(action: {
            // Tap action
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(verse.reference.verse)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .leading)

                    Spacer()

                    if let _ = highlightManager.getHighlightColor(for: verse.reference) {
                        Button(action: {
                            haptics.impact(.light)
                            highlightManager.removeHighlight(verse.reference)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    if hasCommentary {
                        Button(action: {
                            haptics.impact(.light)
                            showingCommentary = true
                        }) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Button(action: {
                        haptics.impact(.medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedVerse = verse
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Render verse using RedVerseText (UILabel)
                let _ = print("DEBUG-VERSE-CARD: About to create RedVerseText with verse: \(verse.text.prefix(30))...")
                let _ = print("DEBUG-VERSE-CARD: Contains <red>: \(verse.text.contains("<red>"))")
                RedVerseText(verse: verse.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                    .background(
                        highlightManager.getHighlightColor(for: verse.reference) ?? Color.clear
                    )
                    .cornerRadius(4)
                    .id(verse.reference.id)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCommentary) {
            CommentaryView(
                book: verse.reference.book,
                chapter: verse.reference.chapter,
                verse: verse.reference.verse
            )
        }
        .onAppear {
            hasCommentary = translationService.hasCommentary(
                for: verse.reference.book,
                chapter: verse.reference.chapter,
                verse: verse.reference.verse
            )
        }
    }
}
    
    func getFontForFamily(_ family: String, size: Double) -> Font {
        switch family {
        case "Serif":
            return Font.custom("Georgia", size: size)
        case "Sans-serif":
            return Font.custom("Helvetica Neue", size: size)
        case "Monospace":
            return Font.custom("Courier", size: size)
        default:
            return Font.system(size: size)
        }
    }


struct VerseCommentaryView: View {
    let book: String
    let chapter: Int
    let verse: Int
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var translationService = TranslationService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(book) \(chapter):\(verse)")
                        .font(.headline)
                    
                    if let commentary = translationService.getVerseCommentary(
                        for: book,
                        chapter: chapter,
                        verse: verse
                    ) {
                        Text(commentary)
                            .font(.body)
                            .lineSpacing(6)
                    } else {
                        Text("No commentary available for this verse.")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Commentary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    VerseCard(
        verse: VerseItem(
            number: 1,
            text: "In the beginning God created the heaven and the earth.",
            reference: VerseReference(book: "Genesis", chapter: 1, verse: 1)
        ),
        selectedVerse: .constant(nil)
    )
}
