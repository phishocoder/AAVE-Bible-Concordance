import SwiftUI
import FullStory

struct DemoDiagnosticsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Diagnostics")
                .font(.headline)
            Button("Generate Test Session") {
                FS.page(withName: "Home")
                FS.event("demo_click", properties: [:])
                print("🔔 Fired page+event")
            }
        }
        .onAppear {
            let ok = Bundle.main.url(forResource: "FullStory", withExtension: "json") != nil
            print(ok ? "✅ FullStory.json present" : "❌ FullStory.json missing")
        }
        .padding()
    }
}
