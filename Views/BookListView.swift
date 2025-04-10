import SwiftUI

struct BookListView: View {
    @StateObject private var verseManager = VerseManager.shared
    @State private var selectedTestament: Testament? = .old
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()

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
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(value: book) {
                        BookRow(book: book, verseManager: verseManager)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search books")
            .navigationTitle("Bible Books")
            .refreshable {
                await verseManager.refreshAvailableBooks()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TestamentPicker(selectedTestament: $selectedTestament)
                }
            }
            .navigationDestination(for: BibleBook.self) { book in
                ChapterListView(book: book.name)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToChapterScreen"))) { notification in
            guard let userInfo = notification.userInfo,
                  let bookName = userInfo["book"] as? String,
                  let chapter = userInfo["chapter"] as? Int,
                  let matchedBook = bibleBooks.first(where: { $0.name == bookName }) else {
                return
            }

            DispatchQueue.main.async {
                NavigationManager.shared.currentBook = bookName
                NavigationManager.shared.currentChapter = chapter
                navigationPath.append(matchedBook)
            }
        }
    }

    // MARK: - BookRow
    struct BookRow: View {
        let book: BibleBook
        @ObservedObject var verseManager: VerseManager
        @ObservedObject private var translationService = TranslationService.shared
        @ObservedObject private var settings = SettingsViewModel.shared

        var isAvailableInAAVE: Bool {
            translationService.isAAVEAvailable(for: book.name)
        }

        var hasAAVEFile: Bool {
            translationService.hasAAVEFile(for: book.name)
        }

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(book.name)
                        .font(.body)

                    if isAvailableInAAVE {
                        Text("AVAILABLE IN AAVE")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if hasAAVEFile {
                        Text("AAVE TRANSLATION COMING SOON")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Spacer()

                if isAvailableInAAVE {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.green)
                } else if hasAAVEFile {
                    Image(systemName: "hourglass")
                        .foregroundColor(.orange)
                }
            }
            .padding(.vertical, 4)
        }
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
