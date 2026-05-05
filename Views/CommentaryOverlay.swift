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
    @ObservedObject private var settings = SettingsViewModel.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var verseText: String?
    @State private var isLoadingVerse = true
    @State private var showShareSheet = false
    
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

                if let verseText {
                    commentarySection(
                        title: "Scripture Translation",
                        caption: settings.preferredTranslation,
                        systemImage: "text.book.closed",
                        content: verseText
                    )
                } else if isLoadingVerse {
                    ProgressView("Loading verse…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let commentary = commentaryText {
                    commentarySection(
                        title: "Real Talk Commentary",
                        caption: "Reflection and teaching layer",
                        systemImage: "lightbulb.fill",
                        content: commentary
                    )

                    HStack(spacing: 10) {
                        actionButton(title: "Copy", systemImage: "doc.on.doc") {
                            UIPasteboard.general.string = shareText(commentary: commentary)
                        }

                        actionButton(title: "Share", systemImage: "square.and.arrow.up") {
                            showShareSheet = true
                        }
                    }
                } else {
                    Text("No commentary available for this verse.")
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
            .glassCard()
            .padding(.horizontal, 24)
        }
        .task(id: "\(verse.id)-\(settings.preferredTranslation)") {
            await loadVerseText()
        }
        .sheet(isPresented: $showShareSheet) {
            if let commentary = commentaryText {
                ShareSheet(items: [shareText(commentary: commentary)])
            }
        }
    }

    private var commentaryText: String? {
        translationService.getVerseCommentary(
            for: verse.book,
            chapter: verse.chapter,
            verse: verse.verse
        )
    }

    private func commentarySection(title: String, caption: String, systemImage: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(systemImage == "lightbulb.fill" ? .yellow : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(content)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.2), lineWidth: 1)
                )
        )
    }

    private func actionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                )
        }
        .buttonStyle(.plain)
    }

    private func shareText(commentary: String) -> String {
        let referenceLine = verse.displayString
        let appLink = "\n\nRead more: https://officialaavebible.com"
        guard let verseText, !verseText.isEmpty else {
            return "\(referenceLine)\n\nCommentary\n\(commentary)\(appLink)"
        }

        return "\(referenceLine)\n\nScripture (\(settings.preferredTranslation))\n\(verseText)\n\nCommentary\n\(commentary)\(appLink)"
    }

    private func loadVerseText() async {
        isLoadingVerse = true
        defer { isLoadingVerse = false }

        do {
            verseText = try await translationService.getVerseTranslation(
                for: verse.book,
                chapter: verse.chapter,
                verse: verse.verse,
                translation: settings.preferredTranslation
            )
        } catch {
            verseText = nil
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
