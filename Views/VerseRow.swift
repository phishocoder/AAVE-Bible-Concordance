//
//  VerseRow.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

@MainActor
struct VerseRow: View {
    let verse: Verse
    let isMultiSelectMode: Bool
    let isSelected: Bool
    let isFocused: Bool
    let hasCommentary: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onCommentaryTap: () -> Void
    
    @ObservedObject private var highlightManager = HighlightManager.shared
    @ObservedObject private var settings = SettingsViewModel.shared
    @ObservedObject private var readingProgress = ReadingProgressService.shared
    private let haptics = HapticManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let highlightColor = highlightManager.getHighlightColor(for: verse.reference)
        let cardFill = colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.75)
        let strokeOpacity = colorScheme == .dark ? 0.08 : 0.25
        let focusFill = colorScheme == .dark ? Color.yellow.opacity(0.18) : Color.yellow.opacity(0.12)
        let focusStroke = Color.yellow.opacity(colorScheme == .dark ? 0.6 : 0.8)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(verse.reference.verse)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            LinearGradient(colors: [Color.accentColor, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    if highlightColor != nil {
                        Text("Highlighted")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if isMultiSelectMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    }
                    
                    if hasCommentary {
                        Button(action: onCommentaryTap) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if highlightColor != nil {
                        Button {
                            highlightManager.removeHighlight(verse.reference)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Text(verse.text)
                .font(getFont(for: settings.fontFamily, size: settings.fontSize))
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(highlightColor ?? (colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.6)))
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(strokeOpacity), lineWidth: isSelected ? 2 : 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(focusStroke, lineWidth: isFocused ? 2 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(isFocused ? focusFill : Color.clear)
                        )
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 12, x: 0, y: 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture {
            haptics.impact(.medium)
            onLongPress()
        }
        .onAppear {
            readingProgress.markVerseRead(verse.reference)
        }
    }
    
    private func getFont(for family: String, size: Double) -> Font {
        switch family.lowercased() {
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
