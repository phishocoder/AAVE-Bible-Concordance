import SwiftUI

@main
struct AAVE_Bible_ConcordanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var appState = AppState()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var notificationNavigationBridge = NotificationNavigationBridge.shared
    @StateObject private var router = NavigationRouter()
    @StateObject private var appleAuthManager = AppleAuthManager.shared
    @AppStorage("selectedTab") private var selectedTabRawValue: String = AppTab.home.rawValue
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    SplashView()
                        .environmentObject(appState)
                        .environmentObject(settings)
                        .environmentObject(networkMonitor)
                        .environmentObject(appleAuthManager)
                        .preferredColorScheme(getPreferredColorScheme())
                        .environmentObject(router)
                } else {
                    ContentView()
                        .preferredColorScheme(getPreferredColorScheme())
                        .environmentObject(settings)
                        .environmentObject(appState)
                        .environmentObject(networkMonitor)
                        .environmentObject(router)
                        .environmentObject(appleAuthManager)
                        .onAppear {
                            notificationManager.incrementAppLaunchCount()
                            // Schedule notifications if enabled
                            notificationManager.scheduleVerseOfDayNotification()
                            
                            // Attempt to restore Sign in with Apple without prompting the user again.
                            appleAuthManager.restorePreviousSignIn()
                            
                            // Update verse of day content for today's notification
                            notificationManager.updateVerseOfDayContent {
                                #if DEBUG
                                print("Verse of day notification content updated")
                                #endif
                            }
                        }
                }
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onAppear {
                consumePendingNotificationRouteIfNeeded()
            }
            .onChange(of: notificationNavigationBridge.pendingRoute) { _, _ in
                consumePendingNotificationRouteIfNeeded()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                notificationManager.recordAppForeground(at: Date())
                DailyVerseLiveActivityCoordinator.handleAppActive()
                consumePendingNotificationRouteIfNeeded()
            }
        }
    }
    
    private func getPreferredColorScheme() -> ColorScheme? {
        switch settings.appearanceMode {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "aavebible" else { return }
        let components = url.pathComponents
        guard components.count >= 3, components[1] == "verse" else { return }

        let verseId = components[2]
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let mode = urlComponents?.queryItems?.first(where: { $0.name == "mode" })?.value
        let version = urlComponents?.queryItems?.first(where: { $0.name == "version" })?.value
        if let mode, let version {
            #if DEBUG
            print("LA-DEBUG deep link mode=\(mode) version=\(version)")
            #endif
        }

        guard let reference = VerseOfDayProvider.reference(forVerseId: verseId) else { return }

        selectedTabRawValue = AppTab.bible.rawValue
        router.requestDeepLink(.verseDetail(reference: reference))
    }

    private func consumePendingNotificationRouteIfNeeded() {
        guard let route = notificationNavigationBridge.consume() else { return }
        selectedTabRawValue = AppTab.bible.rawValue
        router.requestDeepLink(route)
    }
}
