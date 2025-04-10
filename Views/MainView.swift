import SwiftUI
import Combine

struct MainView: View {
    @StateObject private var navigationManager = NavigationManager.shared
    @State private var navPath = NavigationPath()
    @State private var forceRefreshID = UUID()
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, search, bookmarks, more
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack(path: $navPath) {
                HomeView()
                    .navigationDestination(for: String.self) { bookName in
                        ChapterListView(book: bookName)
                    }
                    .navigationDestination(for: BookChapterPair.self) { pair in
                        VerseListView(book: pair.book, chapter: pair.chapter)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)
            
            // Search Tab
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)
            
            // Bookmarks Tab
            NavigationStack {
                BookmarkView()
            }
            .tabItem {
                Label("Bookmarks", systemImage: "bookmark")
            }
            .tag(Tab.bookmarks)
            
            // More Tab
            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
            .tag(Tab.more)
        }
        .environmentObject(navigationManager)
        .id(forceRefreshID)
        .onReceive(navigationManager.$navigationRequest) { request in
            guard let request = request else { return }
            
            // Switch to home tab
            selectedTab = .home
            
            // Reset the navigation path and build a new one
            navPath = NavigationPath()
            
            // Add the book to the path
            navPath.append(request.book)
            
            // If chapter is specified, add it too
            if request.chapter > 0 {
                navPath.append(BookChapterPair(book: request.book, chapter: request.chapter))
            }
            
            // Force refresh the entire view
            forceRefreshID = UUID()
            
            // If verse should be highlighted, post notification
            if let verse = request.verse, request.highlightVerse {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(
                        name: Notification.Name("HighlightVerse"),
                        object: nil,
                        userInfo: [
                            "book": request.book,
                            "chapter": request.chapter,
                            "verse": verse
                        ]
                    )
                }
            }
            
            // Clear the request after processing
            DispatchQueue.main.async {
                NavigationManager.shared.clearNavigationRequest()
            }
        }
    }
}
