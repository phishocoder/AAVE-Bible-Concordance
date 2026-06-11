//
//  VerseRow.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/17/25.
//

import SwiftUI

struct VerseRow: View, Equatable {
    let verse: Verse
    let isMultiSelectMode: Bool
    let isSelected: Bool
    let isFocused: Bool
    let hasCommentary: Bool
    let highlightColor: Color?
    let fontFamily: String
    let fontSize: Double
    let colorScheme: ColorScheme
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onCommentaryTap: () -> Void
    let onRemoveHighlight: () -> Void
    let onAppear: () -> Void
    
    private let haptics = HapticManager.shared
    
    var body: some View {
        let cardFill = colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.75)
        let strokeOpacity = colorScheme == .dark ? 0.08 : 0.25
        let focusFill = colorScheme == .dark ? Color.yellow.opacity(0.18) : Color.yellow.opacity(0.12)
        let focusStroke = Color.yellow.opacity(colorScheme == .dark ? 0.6 : 0.8)
        let selectionFill = colorScheme == .dark ? Color.accentColor.opacity(0.14) : Color.accentColor.opacity(0.08)
        let selectionStroke = Color.accentColor.opacity(colorScheme == .dark ? 0.7 : 0.45)
        
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
                        Button(action: onRemoveHighlight) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Text(verse.text)
                .font(verseFont)
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
                .fill(isSelected ? selectionFill : cardFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isSelected ? selectionStroke : Color.white.opacity(strokeOpacity), lineWidth: isSelected ? 2 : 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(focusStroke, lineWidth: isFocused ? 2 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(isFocused ? focusFill : Color.clear)
                        )
                )
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(selectionStroke)
                        .frame(width: 4)
                        .padding(.vertical, 14)
                        .padding(.leading, 10)
                        .opacity(isSelected ? 1 : 0)
                }
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
        .onAppear(perform: onAppear)
    }
    
    private var verseFont: Font {
        switch fontFamily.lowercased() {
        case "serif":
            return .system(size: fontSize, weight: .regular, design: .serif)
        case "rounded":
            return .system(size: fontSize, weight: .regular, design: .rounded)
        case "monospaced":
            return .system(size: fontSize, weight: .regular, design: .monospaced)
        default:
            return .system(size: fontSize, weight: .regular, design: .default)
        }
    }

    static func == (lhs: VerseRow, rhs: VerseRow) -> Bool {
        lhs.verse == rhs.verse
            && lhs.isMultiSelectMode == rhs.isMultiSelectMode
            && lhs.isSelected == rhs.isSelected
            && lhs.isFocused == rhs.isFocused
            && lhs.hasCommentary == rhs.hasCommentary
            && lhs.highlightColor == rhs.highlightColor
            && lhs.fontFamily == rhs.fontFamily
            && lhs.fontSize == rhs.fontSize
            && lhs.colorScheme == rhs.colorScheme
    }
}
