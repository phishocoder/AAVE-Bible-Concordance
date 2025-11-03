import SwiftUI

@main
struct AAVE_FSDemoApp: App {
    @UIApplicationDelegateAdaptor(DemoAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
