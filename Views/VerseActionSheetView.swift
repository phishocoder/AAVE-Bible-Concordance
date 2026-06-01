import SwiftUI
import UIKit

enum VerseActionSheetAction {
    case select
    case highlight
    case bookmark
    case note
    case copy
    case share
    case verseImage
    case compareTranslation
}

struct VerseActionSheetView: View {
    let verse: Verse
    let translationLabel: String?
    let isBookmarked: Bool
    let isHighlighted: Bool
    let currentHighlightColor: Color?
    let showsHighlightPalette: Bool
    let onAction: (VerseActionSheetAction) -> Void
    let onHighlightColor: (Color) -> Void
    let onRemoveHighlight: () -> Void
    let onCancel: () -> Void

    private let highlightColors: [(name: String, color: Color)] = [
        ("Yellow", Color(red: 0.98, green: 0.85, blue: 0.20)),
        ("Green", Color(red: 0.20, green: 0.86, blue: 0.45)),
        ("Blue", Color(red: 0.30, green: 0.67, blue: 0.97)),
        ("Pink", Color(red: 0.96, green: 0.42, blue: 0.71))
    ]

    private var actions: [TrayAction] {
        [
            TrayAction(
                title: "Select",
                icon: "checkmark.circle",
                isActive: false,
                action: { onAction(.select) }
            ),
            TrayAction(
                title: "Highlight",
                icon: isHighlighted ? "highlighter" : "highlighter",
                isActive: isHighlighted || showsHighlightPalette,
                action: { onAction(.highlight) }
            ),
            TrayAction(
                title: "Bookmark",
                icon: isBookmarked ? "bookmark.fill" : "bookmark",
                isActive: isBookmarked,
                action: { onAction(.bookmark) }
            ),
            TrayAction(
                title: "Note",
                icon: "note.text",
                isActive: false,
                action: { onAction(.note) }
            ),
            TrayAction(
                title: "Copy",
                icon: "doc.on.doc",
                isActive: false,
                action: { onAction(.copy) }
            ),
            TrayAction(
                title: "Share",
                icon: "square.and.arrow.up",
                isActive: false,
                action: { onAction(.share) }
            ),
            TrayAction(
                title: "Compare Translation",
                icon: "doc.text.magnifyingglass",
                isActive: false,
                action: { onAction(.compareTranslation) }
            ),
            TrayAction(
                title: "Verse Image",
                icon: "photo",
                isActive: false,
                action: { onAction(.verseImage) }
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(actions) { action in
                    trayButton(for: action)
                }
            }

            if showsHighlightPalette {
                highlightPalette
            }

            HStack {
                Spacer()
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .background(.thinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verse.reference.displayString)
                .font(.headline.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.9)
            if let translationLabel, !translationLabel.isEmpty {
                Text(translationLabel)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var highlightPalette: some View {
        HStack(spacing: 10) {
            ForEach(highlightColors, id: \.name) { item in
                Button {
                    onHighlightColor(item.color)
                } label: {
                    Circle()
                        .fill(item.color)
                        .frame(width: 34, height: 34)
                        .shadow(color: item.color.opacity(0.35), radius: 6, x: 0, y: 3)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelectionVisible(item.color) ? Color.white.opacity(0.95) : Color.white.opacity(0.35),
                                    lineWidth: isSelectionVisible(item.color) ? 2.5 : 1
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Highlight \(item.name)")
                .frame(minWidth: 44, minHeight: 44)
            }

            if isHighlighted {
                Button(action: onRemoveHighlight) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .frame(minHeight: 34)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.12))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.red.opacity(0.32), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityLabel("Remove highlight")
            }
        }
        .padding(.top, 2)
    }

    private func isSelectionVisible(_ color: Color) -> Bool {
        guard isHighlighted else { return false }
        guard let currentHighlightColor else { return false }
        let lhs = UIColor(color)
        let rhs = UIColor(currentHighlightColor)
        var lRed: CGFloat = 0
        var lGreen: CGFloat = 0
        var lBlue: CGFloat = 0
        var lAlpha: CGFloat = 0
        var rRed: CGFloat = 0
        var rGreen: CGFloat = 0
        var rBlue: CGFloat = 0
        var rAlpha: CGFloat = 0

        guard lhs.getRed(&lRed, green: &lGreen, blue: &lBlue, alpha: &lAlpha),
              rhs.getRed(&rRed, green: &rGreen, blue: &rBlue, alpha: &rAlpha) else {
            return false
        }

        let tolerance: CGFloat = 0.06
        return abs(lRed - rRed) < tolerance &&
        abs(lGreen - rGreen) < tolerance &&
        abs(lBlue - rBlue) < tolerance &&
        abs(lAlpha - rAlpha) < tolerance
    }

    private func trayButton(for action: TrayAction) -> some View {
        Button(action: action.action) {
            VStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(action.isActive ? Color.accentColor : Color.primary)
                    .frame(width: 28, height: 28)

                Text(action.title)
                    .font(.caption.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 64)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(action.isActive ? Color.accentColor.opacity(0.12) : Color.white.opacity(0.001))
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

private struct TrayAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void
}

struct VerseActionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerseActionSheetView(
                verse: Verse(
                    text: "The message of the cross is foolishness to those who are perishing.",
                    translation: "AAVE",
                    reference: VerseReference(book: "1 Corinthians", chapter: 1, verse: 18)
                ),
                translationLabel: "AAVE",
                isBookmarked: true,
                isHighlighted: true,
                currentHighlightColor: Color(red: 0.98, green: 0.85, blue: 0.20),
                showsHighlightPalette: true,
                onAction: { _ in },
                onHighlightColor: { _ in },
                onRemoveHighlight: {},
                onCancel: {}
            )
            .previewDisplayName("iPhone SE")
            .previewDevice("iPhone SE (3rd generation)")

            VerseActionSheetView(
                verse: Verse(
                    text: "The message of the cross is foolishness to those who are perishing.",
                    translation: "AAVE",
                    reference: VerseReference(book: "1 Corinthians", chapter: 1, verse: 18)
                ),
                translationLabel: "AAVE",
                isBookmarked: false,
                isHighlighted: false,
                currentHighlightColor: nil,
                showsHighlightPalette: false,
                onAction: { _ in },
                onHighlightColor: { _ in },
                onRemoveHighlight: {},
                onCancel: {}
            )
            .previewDisplayName("iPhone 15 Pro")
            .previewDevice("iPhone 15 Pro")
        }
    }
}
