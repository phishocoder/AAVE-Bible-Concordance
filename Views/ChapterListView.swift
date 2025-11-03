import SwiftUI

struct ChapterListView: View {
    let book: String
    @StateObject private var translationService = TranslationService.shared
    @State private var error: Error?
    
    private var isAAVEAvailable: Bool {
        translationService.isAAVEAvailable(for: book)
    }
    
    private var hasAAVEFile: Bool {
        translationService.hasAAVEFile(for: book)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                statusCard

                if !translationService.isLoaded {
                    ProgressView("Loading translations...")
                        .padding()
                        .glassCard()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(1...numberOfChapters, id: \.self) { chapter in
                            NavigationLink {
                                VerseListView(book: book, chapter: chapter)
                                    .environmentObject(NavigationManager.shared)
                            } label: {
                                ChapterRow(number: chapter, availability: availability)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .scrollIndicators(.hidden)
        .glassBackground()
        .navigationTitle(book)
        .applyGlassToolbar()
        .task {
            if !translationService.isLoaded {
                do {
                    try await translationService.loadTranslations()
                } catch {
                    self.error = error
                }
            }
        }
        .alert("Error Loading Translations", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Button("OK", role: .cancel) { error = nil }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
    }

    private var numberOfChapters: Int {
        bibleBooks.first { $0.name == book }?.chapters ?? 0
    }

    private var availability: ChapterAvailability {
        if isAAVEAvailable {
            return .available
        }
        if hasAAVEFile {
            return .comingSoon
        }
        return .traditional
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chapter Overview")
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 12) {
                Image(systemName: availability.icon)
                    .foregroundStyle(availability.tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(availability.title)
                        .fontWeight(.medium)
                    Text(availability.subtitle(for: numberOfChapters))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .glassCard()
    }
}

private enum ChapterAvailability {
    case available
    case comingSoon
    case traditional

    var title: String {
        switch self {
        case .available: return "Available in AAVE"
        case .comingSoon: return "AAVE translation coming soon"
        case .traditional: return "Traditional translation"
        }
    }

    var icon: String {
        switch self {
        case .available: return "doc.text.fill"
        case .comingSoon: return "hourglass"
        case .traditional: return "book.fill"
        }
    }

    var tint: Color {
        switch self {
        case .available: return .green
        case .comingSoon: return .orange
        case .traditional: return .blue
        }
    }

    func subtitle(for chapters: Int) -> String {
        "\(chapters) chapters in this book"
    }
}

private struct ChapterRow: View {
    let number: Int
    let availability: ChapterAvailability
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Chapter \(number)")
                    .font(.headline)
                Text(availability.title)
                    .font(.caption)
                    .foregroundStyle(availability.tint)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 12, x: 0, y: 8)
    }
}
