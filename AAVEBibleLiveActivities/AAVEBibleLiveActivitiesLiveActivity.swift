//
//  AAVEBibleLiveActivitiesLiveActivity.swift
//  AAVEBibleLiveActivities
//
//  Created by Phil Shobo on 1/20/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AAVEBibleLiveActivitiesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DailyVerseAttributes.self) { context in
            LockScreenDailyVerseView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            dynamicIslandContent(for: context.state)
        }
    }
}

struct LockScreenDailyVerseView: View {
    let state: DailyVerseAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                IconMark(size: 24)
                Text("Daily Verse")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }

            Text(state.reference)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .layoutPriority(1)

            HStack(spacing: 6) {
                Text(state.versionLabel)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                if state.isJesusSaid {
                    Text("Jesus Said")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Text(state.excerpt)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .layoutPriority(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .widgetURL(deepLinkURL(for: state))
    }
}

private func dynamicIslandContent(for state: DailyVerseAttributes.ContentState) -> DynamicIsland {
    DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
            HStack(spacing: 6) {
                IconMark(size: 18)
                Text("Daily Verse")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        DynamicIslandExpandedRegion(.trailing) {
            VStack(alignment: .trailing, spacing: 2) {
                Text(shortBookRef(from: state.reference))
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        DynamicIslandExpandedRegion(.bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(state.reference)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .layoutPriority(1)

                HStack(spacing: 6) {
                    Text(state.versionLabel)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    if state.isJesusSaid {
                        Text("Jesus Said")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                Text(state.excerpt)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .layoutPriority(1)
            }
        }
    } compactLeading: {
        IconMark(size: 16, fallbackSystemName: state.isJesusSaid ? "quote.bubble.fill" : "book.closed")
    } compactTrailing: {
        Text(shortBookRef(from: state.reference))
            .font(.caption2)
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    } minimal: {
        IconMark(size: 16, fallbackSystemName: state.isJesusSaid ? "quote.bubble.fill" : "book.closed")
    }
    .widgetURL(deepLinkURL(for: state))
}

struct IconMark: View {
    let size: CGFloat
    var fallbackSystemName: String = "book.closed"

    var body: some View {
        if let image = UIImage(named: "AAVEBibleLogoMark") {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        } else {
            Image(systemName: fallbackSystemName)
                .foregroundColor(.white)
        }
    }
}

private func deepLinkURL(for state: DailyVerseAttributes.ContentState) -> URL? {
    let mode = state.isJesusSaid ? "jesusSaid" : "daily"
    var components = URLComponents()
    components.scheme = "aavebible"
    components.host = "verse"
    components.path = "/\(state.verseId)"
    components.queryItems = [
        URLQueryItem(name: "mode", value: mode),
        URLQueryItem(name: "version", value: state.versionLabel)
    ]
    return components.url
}

private func shortBookRef(from reference: String) -> String {
    let parts = reference.split(separator: " ")
    guard parts.count >= 2 else { return reference }

    let chapterVerse = String(parts.last ?? "")
    let bookParts = parts.dropLast()

    var index = 0
    var numberPrefix: String?
    if let first = bookParts.first, ["1", "2", "3"].contains(first) {
        numberPrefix = String(first)
        index = 1
    }

    guard bookParts.indices.contains(index) else { return reference }
    let bookWord = String(bookParts[index])
    let abbreviation = abbreviateBook(bookWord)
    let bookPrefix = numberPrefix != nil ? "\(numberPrefix!) \(abbreviation)" : abbreviation

    return "\(bookPrefix) \(chapterVerse)"
}

private func abbreviateBook(_ book: String) -> String {
    let map: [String: String] = [
        "matthew": "Matt",
        "corinthians": "Cori",
        "philippians": "Phil",
        "revelation": "Reve",
        "thessalonians": "Thes",
        "deuteronomy": "Deut"
    ]

    let lower = book.lowercased()
    if let mapped = map[lower] {
        return ensureMinimumLength(mapped, from: book)
    }

    return ensureMinimumLength(String(book.prefix(4)), from: book)
}

private func ensureMinimumLength(_ candidate: String, from original: String) -> String {
    if candidate.count >= 4 || original.count <= 4 {
        return original.count <= 4 ? original : candidate
    }
    return String(original.prefix(4))
}

#if DEBUG
private func debugShortBookRefSamples() {
    let samples = [
        "Matthew 5:7",
        "Mark 1:1",
        "John 3:16",
        "1 John 4:8",
        "2 Corinthians 5:17",
        "Philippians 4:13",
        "Revelation 21:4",
        "Song of Solomon 2:4"
    ]

    for sample in samples {
        print("LA-DEBUG shortRef \(sample) -> \(shortBookRef(from: sample))")
    }
}

private let _shortRefDebug: Void = {
    debugShortBookRefSamples()
}()
#endif

#Preview("Notification", as: .content, using: DailyVerseAttributes(activityId: "preview")) {
    AAVEBibleLiveActivitiesLiveActivity()
} contentStates: {
    DailyVerseAttributes.ContentState(reference: "John 3:16", excerpt: "For God loved the world so much that He gave His one and only Son.", verseId: "John-3-16", versionLabel: "AAVE", isJesusSaid: true)
    DailyVerseAttributes.ContentState(reference: "Psalm 23:1", excerpt: "The Lord is my shepherd; I shall not want.", verseId: "Psalm-23-1", versionLabel: "NET", isJesusSaid: false)
}
