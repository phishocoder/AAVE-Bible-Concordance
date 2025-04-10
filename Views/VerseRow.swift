//
//  VerseRow.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

struct VerseRowView: View {
    let verse: Verse
    let isMultiSelectMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @ObservedObject private var highlightManager = HighlightManager.shared
    @ObservedObject private var settings = SettingsViewModel.shared
    @ObservedObject private var userDataManager = UserDataManager.shared
    @ObservedObject private var translationService = TranslationService.shared
    @State private var hasCommentary = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 8) {
                // Selection checkbox in multi-select mode
                if isMultiSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .padding(.top, 2)
                }
                
                // Verse number
                Text("\(verse.reference.verse)")
                    .font(.system(.body, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 24, alignment: .leading)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Verse text with highlight
                    let _ = print("DEBUG-VERSE-ROW: About to create RedVerseText with verse: \(verse.text.prefix(30))...")
                    let _ = print("DEBUG-VERSE-ROW: Contains <red>: \(verse.text.contains("<red>"))")
                    RedVerseText(verse: verse.text)
                        .font(getFontForFamily(settings.fontFamily, size: settings.fontSize))
                        .lineSpacing(4)
                        .foregroundStyle(.primary)
                        .padding(6)
                        .background(
                            highlightManager.getHighlightColor(for: verse.reference) ?? Color.clear
                        )
                        .cornerRadius(4)
                        .id("verse-\(verse.reference.key)-\(highlightManager.highlightUpdateID)")
                    
                    // Commentary indicator if available
                    if hasCommentary {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 12))
                            Text("Commentary available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = "\(verse.reference.book) \(verse.reference.chapter):\(verse.reference.verse) - \(verse.text)"
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            if hasCommentary {
                Button(action: {
                    NotificationCenter.default.post(
                        name: Notification.Name("ShowCommentary"),
                        object: nil,
                        userInfo: ["reference": verse.reference]
                    )
                }) {
                    Label("View Commentary", systemImage: "lightbulb")
                }
            }
            
            Button(action: onLongPress) {
                Label("Select", systemImage: "checkmark.circle")
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onLongPress()
                }
        )
        .onAppear {
            Task {
                hasCommentary = translationService.hasCommentary(
                    for: verse.reference.book,
                    chapter: verse.reference.chapter,
                    verse: verse.reference.verse
                )
            }
        }
    }
    
    private func getFontForFamily(_ family: String, size: CGFloat) -> Font {
        switch family {
        case "serif":
            return .system(size: size, weight: .regular, design: .serif)
        case "rounded":
            return .system(size: size, weight: .regular, design: .rounded)
        case "monospaced":
            return .system(size: size, weight: .regular, design: .monospaced)
        default:
            return .system(size: size, weight: .regular, design: .default)
        }
    }
}
