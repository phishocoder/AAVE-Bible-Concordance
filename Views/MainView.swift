import SwiftUI

struct MainView: View {
    @EnvironmentObject private var router: NavigationRouter
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)
            
            BibleTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(AppTab.bible)
            
            SearchView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)
            
            BookmarkView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
                .tag(AppTab.bookmarks)
            
            NavigationStack {
                MoreView()
            }
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(AppTab.more)
        }
        .glassBackground()
    }
}

private struct BibleTabView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Binding var selectedTab: AppTab
    
    var body: some View {
        NavigationStack(path: $router.path) {
            BookListView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case let .bible(bookID, chapter, verse):
                        VerseListView(book: bookID, chapter: chapter, initialVerse: verse)
                    case let .commentary(bookID, chapter, verse):
                        CommentaryView(book: bookID, chapter: chapter, verse: verse)
                    case .bookmarks:
                        BookmarkView(selectedTab: $selectedTab)
                    }
                }
        }
    }
}
