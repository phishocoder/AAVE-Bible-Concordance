//
//  ConcordanceView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/6/25.
//
import SwiftUI

struct ConcordanceView: View {
    let book: String
    let chapter: Int
    let verse: Int
    private let translationService = TranslationService.shared
    @State private var verseText: String = "Loading..."
    @State private var isLoading = true

    var body: some View {
        VStack {
            Text("\(book) \(chapter):\(verse)")
                .font(.title)
                .padding()
            
            if isLoading {
                ProgressView()
            } else {
                Text(verseText)
                    .padding()
            }
        }
        .navigationTitle("AAVE Breakdown")
        .task {
            do {
                let text = try await translationService.getVerseTranslation(
                    for: book,
                    chapter: chapter,
                    verse: verse,
                    translation: "AAVE"
                )
                await MainActor.run {
                    verseText = text
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    verseText = "Error loading verse"
                    isLoading = false
                }
            }
        }
    }
}
