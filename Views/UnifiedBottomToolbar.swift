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
        get { self[SafeAreaInsetsKey.self]}
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
    
    // Simple vibrant highlight colors
    private let highlightColors: [Color] = [
        .yellow, .green, .blue, .pink, .purple, .orange
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            // Selection count and select all button
            if viewModel.isMultiSelectMode {
                HStack {
                    Text("\(viewModel.selectedVerses.count) verses selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        if areAllVersesSelected() {
                            // Deselect all except the first one
                            if let firstVerse = viewModel.selectedVerses.first {
                                viewModel.selectedVerses = [firstVerse]
                            }
                        } else {
                            selectAllVerses()
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text(areAllVersesSelected() ? "Deselect All" : "Select All")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Simple color picker
            if showingColorPicker {
                HStack(spacing: 12) {
                    ForEach(highlightColors, id: \.self) { color in
                        Button(action: {
                            highlightVerse(with: color)
                            showingColorPicker = false
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Remove highlight button
                    Button(action: {
                        removeHighlight()
                        showingColorPicker = false
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(
                    Color(.systemBackground)
                        .opacity(0.95)
                        .background(.ultraThinMaterial)
                )
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showingColorPicker)
            }
            
            // Main toolbar buttons
            HStack(spacing: 12) {
                // Copy button
                ToolbarButton(
                    icon: "doc.on.doc",
                    label: "Copy",
                    action: {
                        UIPasteboard.general.string = createShareText()
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                
                // Share button
                ToolbarButton(
                    icon: "square.and.arrow.up",
                    label: "Share",
                    action: {
                        shareText = createShareText()
                        showShareSheet = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                
                // Bookmark button
                ToolbarButton(
                    icon: isBookmarked() ? "bookmark.fill" : "bookmark",
                    label: "Bookmark",
                    action: {
                        toggleBookmark()
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                
                // Highlight button
                ToolbarButton(
                    icon: "highlighter",
                    label: "Highlight",
                    action: {
                        withAnimation {
                            showingColorPicker.toggle()
                        }
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                
                // Compare translations button
                ToolbarButton(
                    icon: "doc.text.magnifyingglass",
                    label: "Compare",
                    action: {
                        showingTranslations = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                
                // Image options button
                ToolbarButton(
                    icon: "photo",
                    label: "Image",
                    action: {
                        showingImageOptions = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
                // Move the sheet modifier outside of the ToolbarButton
                .sheet(isPresented: $showingImageOptions) {
                    if let verse = viewModel.selectedVerse {
                        VerseImageCreatorView(verse: verse)
                    }
                }
                
                
                Spacer()
                
                // Cancel button - fixed to prevent wrapping
                Button(action: {
                    if viewModel.isMultiSelectMode {
                        viewModel.isMultiSelectMode = false
                        viewModel.selectedVerses = []
                    } else {
                        viewModel.selectedVerse = nil
                    }
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(minWidth: 60)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .padding(.bottom, safeAreaInsets.bottom > 0 ? safeAreaInsets.bottom - 8 : 0)
        }
        .background(
            Color(.systemBackground)
                .opacity(0.95)
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 3, y: -2)
        )
        .sheet(isPresented: $showingTranslations) {
            NavigationView {
                if viewModel.isMultiSelectMode, let firstVerse = viewModel.selectedVerses.first {
                    TranslationsView(verse: firstVerse)
                } else if let verse = viewModel.selectedVerse {
                    TranslationsView(verse: verse)
                }
            }
        }
        .sheet(isPresented: $showingImageOptions) {
            Text("Image options coming soon")
                .padding()
        }
    }
    
    // Helper component for toolbar buttons
    private struct ToolbarButton: View {
        let icon: String
        let label: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                    Text(label)
                        .font(.caption2)
                }
                .frame(minWidth: 44)
            }
        }
    }
    
    // Add these helper functions
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
            }
        }
    }
}
