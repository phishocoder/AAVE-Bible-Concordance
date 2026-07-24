import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject private var router: NavigationRouter
    @AppStorage("selectedTab") private var selectedTabRawValue: String = AppTab.home.rawValue
    @StateObject private var achievementService = AchievementService.shared
    @State private var isPreparingShare = false
    @State private var shareErrorMessage: String?
    
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
            
            NavigationStack {
                SearchView(selectedTab: selectedTabBinding)
            }
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
                        Task { @MainActor in
                            print("[Share] User initiated share for \(unlock.achievement.title)")
                            isPreparingShare = true
                            if let items = AchievementShareRenderer.shareItems(for: unlock.achievement) {
                                AchievementSharePresenter.present(items: items)
                                achievementService.clearLastUnlocked()
                            } else {
                                shareErrorMessage = "Unable to generate share image. Please try again."
                            }
                            isPreparingShare = false
                        }
                    },
                    onDismiss: {
                        achievementService.clearLastUnlocked()
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            if isPreparingShare {
                ProgressView("Preparing share…")
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .zIndex(2)
            }
        }
        .alert("Share Failed", isPresented: Binding(
            get: { shareErrorMessage != nil },
            set: { if !$0 { shareErrorMessage = nil } }
        )) {
            Button("OK") { shareErrorMessage = nil }
        } message: {
            Text(shareErrorMessage ?? "")
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
                    case let .verseDetail(reference):
                        VerseDetailView(reference: reference)
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
            // A notification can be tapped before this stack exists on a cold launch.
            if let route = router.pendingDeepLink {
                router.pendingDeepLink = nil
                router.resetAndGoTo(route)
                return
            }

            // If we have a saved reading location and no active navigation, restore it.
            if router.path.isEmpty, !lastBook.isEmpty {
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
