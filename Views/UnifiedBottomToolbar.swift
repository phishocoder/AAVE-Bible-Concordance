//
//  UnifiedBottomToolbar.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/19/25.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = EdgeInsets()
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

struct UnifiedBottomToolbar: View {
    @ObservedObject var viewModel: VerseListViewModel
    @Binding var showShareSheet: Bool
    @Binding var shareText: String
    @State private var showingTranslations = false
    @State private var showingColorPicker = false
    @State private var showingImageOptions = false
    @ObservedObject private var highlightManager = HighlightManager.shared
    @ObservedObject private var bookmarks = Bookmarks.shared
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    private let highlightColors: [Color] = [.yellow, .green, .blue, .pink, .purple, .orange]
    
    var body: some View {
        VStack(spacing: 6) {
            Divider()

            HStack(alignment: .center, spacing: 12) {
                if viewModel.isMultiSelectMode {
                    Text("\(viewModel.selectedVerses.count) verses selected")
                        .font(AAVETypography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(action: toggleSelectAll) {
                        Text(areAllVersesSelected() ? "Deselect All" : "Select All")
                            .font(AAVETypography.caption)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer()
                }

                Button(action: dismissSelection) {
                    Text("Cancel")
                        .font(AAVETypography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color.white.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)

            if showingColorPicker {
                HStack(spacing: 12) {
                    Spacer(minLength: 0)
                    ForEach(highlightColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                highlightVerse(with: color)
                                showingColorPicker = false
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                    }

                    Button(action: {
                        removeHighlight()
                        showingColorPicker = false
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 40)
            }

            HStack(spacing: 14) {
                ToolbarButton(icon: "doc.on.doc") {
                    shareText = createShareText()
                    UIPasteboard.general.string = shareText
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                ToolbarButton(icon: "square.and.arrow.up") {
                    shareText = createShareText()
                    showShareSheet = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    AchievementService.shared.recordShare()
                }
                ToolbarButton(icon: isBookmarked() ? "bookmark.fill" : "bookmark") {
                    toggleBookmark()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                ToolbarButton(icon: "highlighter") {
                    withAnimation(.spring()) {
                        showingColorPicker.toggle()
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                ToolbarButton(icon: "doc.text.magnifyingglass") {
                    showingTranslations = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                ToolbarButton(icon: "photo") {
                    showingImageOptions = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                .sheet(isPresented: $showingImageOptions) {
                    if let verse = viewModel.selectedVerse {
                        VerseImageCreatorView(verse: verse)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, max(safeAreaInsets.bottom, 6))
        }
        .background(
            Color(.systemBackground)
                .opacity(0.94)
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 6, y: -2)
                .edgesIgnoringSafeArea(.bottom)
        )
        .sheet(isPresented: $showingTranslations) {
            compareSheet
        }
        .sheet(isPresented: $showingImageOptions) {
            Text("Image options coming soon")
                .padding()
        }
    }
    
    private func dismissSelection() {
        if viewModel.isMultiSelectMode {
            viewModel.isMultiSelectMode = false
            viewModel.selectedVerses = []
        } else {
            viewModel.selectedVerse = nil
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func toggleSelectAll() {
        if areAllVersesSelected() {
            if let firstVerse = viewModel.selectedVerses.first {
                viewModel.selectedVerses = [firstVerse]
            }
        } else {
            selectAllVerses()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private var compareSheet: some View {
        Group {
            if let verse = viewModel.isMultiSelectMode ? viewModel.selectedVerses.first : viewModel.selectedVerse {
                CompareTranslationsSheet(reference: verse.reference, aave: verse.text)
            } else {
                NavigationView {
                    Text("Select a verse to compare translations.")
                        .glassCard()
                        .padding(24)
                        .glassBackground()
                        .navigationTitle("Compare")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { showingTranslations = false }
                            }
                        }
                }
            }
        }
    }
    
    private struct ToolbarButton: View {
        let icon: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(AAVETypography.toolbarIcon)
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func areAllVersesSelected() -> Bool {
        guard !viewModel.verses.isEmpty else { return false }
        return viewModel.selectedVerses.count == viewModel.verses.count
    }
    
    private func selectAllVerses() {
        viewModel.isMultiSelectMode = true
        viewModel.selectedVerses = viewModel.verses
    }
    
    private func highlightVerse(with color: Color) {
        if viewModel.isMultiSelectMode {
            for verse in viewModel.selectedVerses {
                highlightManager.addHighlight(verse.reference, color: color)
            }
        } else if let verse = viewModel.selectedVerse {
            highlightManager.addHighlight(verse.reference, color: color)
        }
    }
    
    private func removeHighlight() {
        if viewModel.isMultiSelectMode {
            for verse in viewModel.selectedVerses {
                highlightManager.removeHighlight(verse.reference)
            }
        } else if let verse = viewModel.selectedVerse {
            highlightManager.removeHighlight(verse.reference)
        }
    }
    
    private func createShareText() -> String {
        if viewModel.isMultiSelectMode {
            return viewModel.selectedVerses.map {
                "\($0.reference.book) \($0.reference.chapter):\($0.reference.verse) \($0.text)"
            }.joined(separator: "\n\n")
        } else if let verse = viewModel.selectedVerse {
            return "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) \(verse.text)"
        }
        return ""
    }
    
    private func isBookmarked() -> Bool {
        if viewModel.isMultiSelectMode {
            guard let firstVerse = viewModel.selectedVerses.first else { return false }
            return bookmarks.isBookmarked(
                book: firstVerse.reference.book,
                chapter: firstVerse.reference.chapter,
                verse: firstVerse.reference.verse
            )
        } else if let verse = viewModel.selectedVerse {
            return bookmarks.isBookmarked(
                book: verse.reference.book,
                chapter: verse.reference.chapter,
                verse: verse.reference.verse
            )
        }
        return false
    }
    
    private func toggleBookmark() {
        if viewModel.isMultiSelectMode {
            for verse in viewModel.selectedVerses {
                if bookmarks.isBookmarked(
                    book: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse
                ) {
                    if let bookmark = bookmarks.bookmarks.first(where: {
                        $0.book == verse.reference.book &&
                        $0.chapter == verse.reference.chapter &&
                        $0.verse == verse.reference.verse
                    }) {
                        bookmarks.removeBookmark(withId: bookmark.id)
                    }
                } else {
                    bookmarks.addBookmark(
                        book: verse.reference.book,
                        chapter: verse.reference.chapter,
                        verse: verse.reference.verse,
                        text: verse.text
                    )
                }
            }
        } else if let verse = viewModel.selectedVerse {
            if bookmarks.isBookmarked(
                book: verse.reference.book,
                chapter: verse.reference.chapter,
                verse: verse.reference.verse
            ) {
                if let bookmark = bookmarks.bookmarks.first(where: {
                    $0.book == verse.reference.book &&
                    $0.chapter == verse.reference.chapter &&
                    $0.verse == verse.reference.verse
                }) {
                    bookmarks.removeBookmark(withId: bookmark.id)
                }
            } else {
                bookmarks.addBookmark(
                    book: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse,
                    text: verse.text
                )
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    private func toggleHighlight() {
        if viewModel.isMultiSelectMode {
            for verse in viewModel.selectedVerses {
                highlightManager.toggleHighlight(verse.reference)
            }
        } else if let verse = viewModel.selectedVerse {
            highlightManager.toggleHighlight(verse.reference)
        }
    }
}
