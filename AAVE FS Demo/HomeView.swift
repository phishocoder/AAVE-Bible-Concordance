import SwiftUI

struct HomeView: View {
    @State private var didInit = false

    var body: some View {
        VStack(spacing: 20) {
            Text("AAVE FS Demo")
                .font(.largeTitle)
                .fontWeight(.bold)

            Image(systemName: "book.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                // Non-sensitive visual; unmask via dashboard rule.
                .accessibilityIdentifier("unmask.logo")

            Button("Browse Verses") {
                FSBridge.event("browse_click", props: ["section": "verses"])
            }
            // Safe content we will explicitly unmask.
            .accessibilityIdentifier("unmask.browseButton")

            Button("Take Quiz") {
                FSBridge.event("quiz_click", props: ["quiz": "daily"])
            }
            // Safe content we will explicitly unmask.
            .accessibilityIdentifier("unmask.quizButton")
        }
        .padding()
        .onAppear {
            guard !didInit else { return }
            didInit = true
            FSBridge.page("Home", props: ["tab": "home"])
        }
    }
}

#Preview {
    HomeView()
}
