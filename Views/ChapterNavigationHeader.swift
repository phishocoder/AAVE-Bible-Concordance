//
//  ChapterNavigationHeader.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

struct ChapterNavigationHeader: View {
    let book: String
    let chapter: Int
    let translation: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onBookTap: () -> Void
    let onTranslationTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("\(book) \(chapter)")
                .font(.headline)
                .onTapGesture(perform: onBookTap)
            
            Spacer()
            
            Button(action: onTranslationTap) {
                Text(translation)
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
