import SwiftUI

struct BookListView: View {
    @StateObject private var verseManager = VerseManager.shared
    @State private var selectedTestament: Testament? = .old
    @State private var searchText = ""

    private var filteredBooks: [BibleBook] {
        let testamentBooks = selectedTestament == nil
            ? bibleBooks
            : bibleBooks.filter { $0.testament == selectedTestament }

        if searchText.isEmpty {
            return testamentBooks
        }
        return testamentBooks.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                filtersCard

                if filteredBooks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book")
                            .font(.largeTitle)
                            .foregroundStyle(Color.accentColor)
                        Text("No books found")
                            .font(.headline)
                        Text("Try adjusting the testament filter or search term.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .glassCard()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredBooks) { book in
                            NavigationLink {
                                ChapterListView(book: book.name)
                            } label: {
                                BookTile(book: book)
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
        .searchable(text: $searchText, prompt: "Search books")
        .navigationTitle("Bible Books")
        .refreshable {
            await verseManager.refreshAvailableBooks()
        }
    }

    private var filtersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse")
                .font(.title3)
                .fontWeight(.semibold)

            TestamentPicker(selectedTestament: $selectedTestament)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Books Available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(filteredBooks.count) of \(bibleBooks.count)")
                    .font(.headline)
            }
        }
        .glassCard()
    }
}

private struct BookTile: View {
    let book: BibleBook
    @ObservedObject private var translationService = TranslationService.shared
    @Environment(\.colorScheme) private var colorScheme

    private var availability: (text: String, icon: String, color: Color) {
        if translationService.isAAVEAvailable(for: book.name) {
            return ("Available in AAVE", "doc.text.fill", .green)
        }
        if translationService.hasAAVEFile(for: book.name) {
            return ("AAVE translation coming soon", "hourglass", .orange)
        }
        return ("Traditional translation", "book", .blue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(book.name)
                        .font(.headline)
                    Text("\(book.chapters) chapters")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: availability.icon)
                    .foregroundStyle(availability.color)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(availability.color.opacity(0.2))
                    .frame(width: 10, height: 10)
                Text(availability.text)
                    .font(.caption)
                    .foregroundStyle(availability.color)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 12, x: 0, y: 10)
    }
}

// MARK: - Preview
#if DEBUG
struct BookListView_Previews: PreviewProvider {
    static var previews: some View {
        BookListView()
    }
}
#endif
