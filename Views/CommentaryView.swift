//
//  CommentaryView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/11/25.
//

import SwiftUI

struct CommentaryArticleText: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.body)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct CommentaryView: View {
    let book: String
    let chapter: Int
    let verse: Int
    @ObservedObject private var translationService = TranslationService.shared
    @ObservedObject private var settings = SettingsViewModel.shared
    
    var body: some View {
        if settings.showCommentary,
           let commentary = translationService.getVerseCommentary(
            for: book,
            chapter: chapter,
            verse: verse
           ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Commentary")
                    .font(.headline)
                CommentaryArticleText(content: commentary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 2)
        }
    }
}
