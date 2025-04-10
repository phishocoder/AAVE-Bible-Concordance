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
        List {
            if !translationService.isLoaded {
                ProgressView("Loading translations...")
            } else {
                if isAAVEAvailable {
                    Section(header: Text("Available in AAVE")) {
                        ForEach(1...numberOfChapters, id: \.self) { chapter in
                            NavigationLink {
                                VerseListView(book: book, chapter: chapter)
                                    .environmentObject(NavigationManager.shared)
                            } label: {
                                HStack {
                                    Text("Chapter \(chapter)")
                                    Spacer()
                                    Image(systemName: "text.book.closed")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    
                    }
                } else if hasAAVEFile {
                    Section(header: Text("AAVE Translation Coming Soon")) {
                        ForEach(1...numberOfChapters, id: \.self) { chapter in
                            NavigationLink {
                                VerseListView(book: book, chapter: chapter)
                                    .environmentObject(NavigationManager.shared)
                            } label: {
                                HStack {
                                    Text("Chapter \(chapter)")
                                    Spacer()
                                    Image(systemName: "hourglass")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                } else {
                    Section(header: Text("Traditional Translation Only")) {
                        ForEach(1...numberOfChapters, id: \.self) { chapter in
                            NavigationLink {
                                VerseListView(book: book, chapter: chapter)
                                    .environmentObject(NavigationManager.shared)
                            } label: {
                                Text("Chapter \(chapter)")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(book)
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
}
