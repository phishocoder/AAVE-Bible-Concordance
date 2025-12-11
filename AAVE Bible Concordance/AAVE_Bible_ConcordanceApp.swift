import SwiftUI

@main
struct AAVE_Bible_ConcordanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var appState = AppState()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var router = NavigationRouter()
    @StateObject private var appleAuthManager = AppleAuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoading {
                SplashView()
                    .environmentObject(appState)
                    .environmentObject(settings)
                    .environmentObject(networkMonitor)
                    .environmentObject(appleAuthManager)
                    .preferredColorScheme(getPreferredColorScheme())
                    .onAppear {
                        // Run the test function when the app starts
                        print("Running red text parsing test...")
                        TextParser.testRedTextParsing()
                    }
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
                        // Run the test function when the app starts
                        print("Running red text parsing test...")
                        TextParser.testRedTextParsing()
                        
                        notificationManager.incrementAppLaunchCount()
                        // Schedule notifications if enabled
                        notificationManager.scheduleVerseOfDayNotification()
                        
                        // Attempt to restore Sign in with Apple without prompting the user again.
                        appleAuthManager.restorePreviousSignIn()
                        
                        // Update verse of day content for today's notification
                        notificationManager.updateVerseOfDayContent {
                            print("Verse of day notification content updated")
                        }
                    }
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
}
