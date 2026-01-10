import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var router: NavigationRouter
    @State private var isLoading = true
    @State private var error: Error? = nil
    @State private var showOnboarding = false
    
    private let translationService = TranslationService.shared
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
            } else {
                MainView()
                    .environmentObject(router)
            }
        }
        .task {
            await initializeApp()
        }
        .onAppear {
            checkForFirstLaunch()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }

    // MARK: - First Launch Check
    private func checkForFirstLaunch() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showOnboarding = true
            }
        }
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
