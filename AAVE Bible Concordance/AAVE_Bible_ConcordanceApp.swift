import SwiftUI

@main
struct AAVE_Bible_ConcordanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var appState = AppState()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoading {
                SplashView()
                    .environmentObject(appState)
                    .environmentObject(settings)
                    .environmentObject(networkMonitor)
                    .preferredColorScheme(getPreferredColorScheme())
                    .onAppear {
                        // Run the test function when the app starts
                        print("Running red text parsing test...")
                        TextParser.testRedTextParsing()
                    }
            } else {
                ContentView()
                    .preferredColorScheme(getPreferredColorScheme())
                    .environmentObject(settings)
                    .environmentObject(appState)
                    .environmentObject(networkMonitor)
                    .onAppear {
                        // Run the test function when the app starts
                        print("Running red text parsing test...")
                        TextParser.testRedTextParsing()
                        
                        notificationManager.incrementAppLaunchCount()
                        // Schedule notifications if enabled
                        notificationManager.scheduleVerseOfDayNotification()
                        
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
