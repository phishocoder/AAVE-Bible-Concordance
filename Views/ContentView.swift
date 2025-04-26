import SwiftUI

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    @State private var selectedTab: Int = 0
    @State private var isLoading = true
    @State private var error: Error? = nil

    private let translationService = TranslationService.shared

    // Environment values for navigation
    private var navigationBook: Binding<String> {
        Binding(
            get: { navigationManager.currentBook },
            set: { navigationManager.currentBook = $0 }
        )
    }

    private var navigationChapter: Binding<Int> {
        Binding(
            get: { navigationManager.currentChapter },
            set: { navigationManager.currentChapter = $0 }
        )
    }

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    NavigationStack {
                        BookListView()
                            .environmentObject(navigationManager)
                    }
                    .tabItem {
                        Label("Bible", systemImage: "book.fill")
                    }
                    .tag(1)

                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(2)

                    MoreView()
                        .tabItem {
                            Label("More", systemImage: "ellipsis.circle.fill")
                        }
                        .tag(4)
                }
                .onReceive(navigationManager.$navigationRequest) { request in
                    guard let request = request else { return }

                    print("ContentView: Received navigation request to \(request.book) \(request.chapter):\(request.verse ?? 0)")

                    // First switch to Bible tab
                    selectedTab = 1

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let verse = request.verse, request.highlightVerse {
                            NotificationCenter.default.post(
                                name: Notification.Name("NavigateToVerse"),
                                object: nil,
                                userInfo: [
                                    "book": request.book,
                                    "chapter": request.chapter,
                                    "verse": verse,
                                    "showDetail": true
                                ]
                            )
                        } else {
                            NotificationCenter.default.post(
                                name: Notification.Name("NavigateToChapter"),
                                object: nil,
                                userInfo: [
                                    "book": request.book,
                                    "chapter": request.chapter
                                ]
                            )
                        }

                        navigationManager.clearNavigationRequest()
                    }
                }
            }
        }
        .environmentObject(navigationManager)
        .task {
            await initializeApp()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DirectNavigateToChapter"))) { notification in
            if let userInfo = notification.userInfo,
               let book = userInfo["book"] as? String,
               let chapter = userInfo["chapter"] as? Int {

                selectedTab = 1

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.navigationManager.navigateToChapter(book: book, chapter: chapter)

                    if let verse = userInfo["verse"] as? Int,
                       let shouldHighlight = userInfo["shouldHighlight"] as? Bool,
                       shouldHighlight {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NotificationCenter.default.post(
                                name: Notification.Name("HighlightVerse"),
                                object: nil,
                                userInfo: [
                                    "book": book,
                                    "chapter": chapter,
                                    "verse": verse
                                ]
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - External Navigation Utility
    func navigateToVerse(_ reference: VerseReference) {
        self.navigationManager.navigateToChapter(book: reference.book, chapter: reference.chapter)
    }

    // MARK: - Initialize App (split out cleanly)
    private func initializeApp() async {
        FirebaseAuthManager.shared.signInAnonymously()

        do {
            try await translationService.loadTranslations()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
