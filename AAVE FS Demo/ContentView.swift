//
//  ContentView.swift
//  AAVE FS Demo
//
//  Created by Phil Shobo on 11/3/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var didInit = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            LoginView()
                .tabItem {
                    Label("Login", systemImage: "person")
                }

            NavigationStack {
                SettingsView()
            }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            guard !didInit else { return }
            didInit = true
            FSBridge.page("App Root", props: ["route": "TabView"])
            if let url = Bundle.main.url(forResource: "FullStory", withExtension: "json"),
               let data = try? Data(contentsOf: url) {
                let previewData = data.prefix(200)
                if let snippet = String(data: Data(previewData), encoding: .utf8) {
                    print("🧪 FullStory.json preview: \(snippet)")
                } else {
                    print("🧪 FullStory.json preview bytes: \(Array(previewData))")
                }
            } else {
                print("⚠️ FullStory.json preview unavailable (file missing or unreadable)")
            }
        }
    }
}

#Preview {
    ContentView()
}
