//
//  HighlightedVersesView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 7/2/25.
//

import SwiftUI

struct HighlightedVersesView: View {
    @ObservedObject var highlightManager = HighlightManager.shared
    @State private var searchText = ""
    
    var filteredHighlights: [HighlightItem] {
        if searchText.isEmpty {
            return highlightManager.highlights
        } else {
            return highlightManager.highlights.filter { highlight in
                "\(highlight.book) \(highlight.chapter):\(highlight.verse)".localizedCaseInsensitiveContains(searchText) ||
                highlight.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredHighlights) { highlight in
                NavigationLink(destination: VerseDetailView(reference: VerseReference(
                    book: highlight.book,
                    chapter: highlight.chapter,
                    verse: highlight.verse
                ))) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(highlight.book) \(highlight.chapter):\(highlight.verse)")
                                .font(.headline)
                            Spacer()
                            Circle()
                                .fill(highlight.color)
                                .frame(width: 16, height: 16)
                        }
                        Text(highlight.text)
                            .font(.body)
                            .lineLimit(3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        highlightManager.removeHighlight(VerseReference(
                            book: highlight.book,
                            chapter: highlight.chapter,
                            verse: highlight.verse
                        ))
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search highlights")
        .navigationTitle("Highlighted Verses")
    }
}
