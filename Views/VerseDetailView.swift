//
//  VerseDetailView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//

import SwiftUI

struct VerseDetailView: View {
    let reference: VerseReference
    
    @StateObject private var translationService = TranslationService.shared
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var userDataManager = UserDataManager.shared
    @ObservedObject private var bookmarks = Bookmarks.shared
    
    @State private var translations: (aave: String?, traditional: String?) = (nil, nil)
    @State private var commentary: String?
    @State private var error: BibleError?
    @State private var showingNotes = false
    @State private var showingCompare = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VerseHeaderCard(reference: reference)

                if let aaveText = translations.aave {
                    TranslationGlassCard(
                        title: "AAVE Translation",
                        badgeGradient: LinearGradient(colors: [.green.opacity(0.9), .mint.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        text: aaveText,
                        fontSize: settings.fontSize,
                        isComingSoon: aaveText.contains("Coming Soon")
                    )
                }

                if let traditionalText = translations.traditional {
                    TranslationGlassCard(
                        title: "NET Translation",
                        badgeGradient: LinearGradient(colors: [.blue.opacity(0.9), .indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        text: traditionalText,
                        fontSize: settings.fontSize
                    )
                }

                VerseToolGrid(
                    isBookmarked: bookmarks.isBookmarked(book: reference.book, chapter: reference.chapter, verse: reference.verse),
                    onBookmark: handleBookmark,
                    onNotes: handleNotes,
                    onShare: handleShare,
                    onCompare: { showingCompare = true }
                )
                .sheet(isPresented: $showingNotes) {
                    NotesView(reference: reference)
                }
                .sheet(isPresented: $showingCompare) {
                    CompareTranslationsSheet(
                        reference: reference,
                        aave: translations.aave,
                        traditional: translations.traditional
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .glassBackground()
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadTranslations() }
        .alert("Error", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func loadTranslations() async {
        do {
            async let aaveText = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "AAVE"
            )
            
            async let traditionalText = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "NET"
            )
            
            translations = try await (aave: aaveText, traditional: traditionalText)
            
            commentary = translationService.getVerseCommentary(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse
            )
            
            userDataManager.addToHistory(reference)
        } catch {
            self.error = error as? BibleError
        }
    }
    
    private func handleBookmark() {
        if bookmarks.isBookmarked(book: reference.book, chapter: reference.chapter, verse: reference.verse) {
            if let bookmark = bookmarks.bookmarks.first(where: {
                $0.book == reference.book &&
                $0.chapter == reference.chapter &&
                $0.verse == reference.verse
            }) {
                bookmarks.removeBookmark(withId: bookmark.id)
            }
        } else {
            let text = translations.aave ?? translations.traditional ?? ""
            bookmarks.addBookmark(
                book: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                text: text
            )
        }
    }
    
    private func handleNotes() {
        showingNotes = true
    }
    
    private func handleShare() {
        var shareText = "\(reference.book) \(reference.chapter):\(reference.verse)\n\n"

        if let aaveText = translations.aave, !aaveText.contains("Coming Soon") {
            shareText += "AAVE: \(aaveText)\n\n"
        }

        if let traditionalText = translations.traditional {
            shareText += "NET: \(traditionalText)"
        }

        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
        AchievementService.shared.recordShare()
    }
}

// MARK: - UI Helpers

private struct VerseHeaderCard: View {
    let reference: VerseReference

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Verse Detail")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("\(reference.book) \(reference.chapter):\(reference.verse)")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .glassCard()
    }
}

private struct VerseToolGrid: View {
    let isBookmarked: Bool
    let onBookmark: () -> Void
    let onNotes: () -> Void
    let onShare: () -> Void
    let onCompare: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            ToolButton(icon: isBookmarked ? "bookmark.fill" : "bookmark", label: "Bookmark", action: onBookmark)
            ToolButton(icon: "note.text", label: "Notes", action: onNotes)
            ToolButton(icon: "square.and.arrow.up", label: "Share", action: onShare)
            ToolButton(icon: "doc.text.magnifyingglass", label: "Compare", action: onCompare)
        }
        .glassCard()
    }

    private struct ToolButton: View {
        let icon: String
        let label: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2)
                    Text(label)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
}

struct TranslationGlassCard: View {
    let title: String
    let badgeGradient: LinearGradient
    let text: String
    let fontSize: Double
    var isComingSoon: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(badgeGradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "text.book.closed")
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    if isComingSoon {
                        Text("Coming soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text(text)
                .font(.system(size: fontSize, weight: .regular, design: .default))
                .lineSpacing(4)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .glassCard()
    }
}

@MainActor
struct CompareTranslationsSheet: View {
    let reference: VerseReference
    let initialAAVE: String?
    let initialTraditional: String?

    @State private var aaveText: String?
    @State private var traditionalText: String?
    @State private var isLoading = false
    @State private var error: Error?

    private let translationService = TranslationService.shared
    @Environment(\.dismiss) private var dismiss

    init(reference: VerseReference, aave: String? = nil, traditional: String? = nil) {
        self.reference = reference
        self.initialAAVE = aave
        self.initialTraditional = traditional
        _aaveText = State(initialValue: aave)
        _traditionalText = State(initialValue: traditional)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView().padding().glassCard()
                    }

                    if let aaveText {
                        TranslationGlassCard(
                            title: "AAVE Translation",
                            badgeGradient: LinearGradient(colors: [.green.opacity(0.9), .mint.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            text: aaveText,
                            fontSize: 16
                        )
                    }

                    if let traditionalText {
                        TranslationGlassCard(
                            title: "NET Translation",
                            badgeGradient: LinearGradient(colors: [.blue.opacity(0.9), .indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            text: traditionalText,
                            fontSize: 16
                        )
                    }

                    if !isLoading && aaveText == nil && traditionalText == nil {
                        Text("No translations available for this verse yet.")
                            .glassCard()
                    }
                }
                .padding(24)
            }
            .glassBackground()
            .navigationTitle("Compare")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task { await loadTranslationsIfNeeded() }
        .alert("Error", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK") { error = nil }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
    }

    private func loadTranslationsIfNeeded() async {
        guard initialAAVE == nil || initialTraditional == nil else { return }
        isLoading = true
        do {
            async let aave = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "AAVE"
            )
            async let net = translationService.getVerseTranslation(
                for: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                translation: "NET"
            )
            let results = try await (aave, net)
            aaveText = initialAAVE ?? results.0
            traditionalText = initialTraditional ?? results.1
            isLoading = false
        } catch {
            isLoading = false
            self.error = error
        }
    }
}
