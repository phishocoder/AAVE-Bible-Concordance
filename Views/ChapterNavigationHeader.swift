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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            NavigationCircle(systemName: "chevron.left", action: onPrevious)

            VStack(alignment: .center, spacing: 4) {
                Text("\(book) \(chapter)")
                    .font(.headline)
                    .onTapGesture(perform: onBookTap)
                Text("Tap translation to switch")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)

            Button(action: onTranslationTap) {
                Text(translation)
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.25), lineWidth: 1)
                    )
            }

            NavigationCircle(systemName: "chevron.right", action: onNext)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 12, x: 0, y: 8)
    }
}

private struct NavigationCircle: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(
                    LinearGradient(colors: [Color.accentColor, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}
