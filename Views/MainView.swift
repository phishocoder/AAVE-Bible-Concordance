import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject private var router: NavigationRouter
    @AppStorage("selectedTab") private var selectedTabRawValue: String = AppTab.home.rawValue
    @StateObject private var achievementService = AchievementService.shared
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false
    
    private var selectedTabBinding: Binding<AppTab> {
        Binding<AppTab>(
            get: { AppTab(rawValue: selectedTabRawValue) ?? .home },
            set: { selectedTabRawValue = $0.rawValue }
        )
    }
    
    var body: some View {
        TabView(selection: selectedTabBinding) {
            NavigationStack {
                HomeView(selectedTab: selectedTabBinding)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)
            
            BibleTabView(selectedTab: selectedTabBinding)
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(AppTab.bible)
            
            SearchView(selectedTab: selectedTabBinding)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)
            
            BookmarkView(selectedTab: selectedTabBinding)
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
        .overlay(alignment: .top) {
            if let unlock = achievementService.lastUnlocked {
                AchievementUnlockToastView(
                    unlock: unlock,
                    onShare: {
                        if let image = AchievementShareCardView.renderImage(for: unlock.achievement) {
                            shareImage = image
                            showShareSheet = true
                            achievementService.clearLastUnlocked()
                        }
                    },
                    onDismiss: {
                        achievementService.clearLastUnlocked()
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }
}

private struct BibleTabView: View {
    @EnvironmentObject private var router: NavigationRouter
    @Binding var selectedTab: AppTab
    @AppStorage("lastBook") private var lastBook: String = "Genesis"
    @AppStorage("lastChapter") private var lastChapter: Int = 1
    @AppStorage("lastVerse") private var lastVerse: Int = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            BookListView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case let .bookChapters(bookID):
                        ChapterListView(book: bookID)
                    case let .bible(bookID, chapter, verse):
                        VerseListView(book: bookID, chapter: chapter, initialVerse: verse)
                    case let .commentary(bookID, chapter, verse):
                        CommentaryView(book: bookID, chapter: chapter, verse: verse)
                    case .bookmarks:
                        BookmarkView(selectedTab: $selectedTab)
                    }
                }
        }
        .onChange(of: selectedTab) { _, newTab in
            guard newTab == .bible else { return }
            if let route = router.pendingDeepLink {
                router.pendingDeepLink = nil
                router.resetAndGoTo(route)
            }
        }
        .onChange(of: router.pendingDeepLink) { _, newRoute in
            guard selectedTab == .bible else { return }
            if let route = newRoute {
                router.pendingDeepLink = nil
                router.resetAndGoTo(route)
            }
        }
        .onAppear {
            // If we have a saved reading location and no active navigation, restore it.
            if router.pendingDeepLink == nil, router.path.isEmpty, !lastBook.isEmpty {
                let safeChapter = max(1, lastChapter)
                let verse = lastVerse > 0 ? lastVerse : nil
                let canonicalBook = BookNameNormalizer.canonicalBookName(lastBook) ?? lastBook
#if DEBUG
                assertCanonicalBook(canonicalBook, context: "MainView.onAppear")
#endif
                router.resetAndGoTo(.bible(bookID: canonicalBook, chapter: safeChapter, verse: verse))
            }
        }
    }
}
