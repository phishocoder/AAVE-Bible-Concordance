import SwiftUI
import AuthenticationServices

struct MoreView: View {
    @State private var showingSettings = false
    @ObservedObject private var userDataManager = UserDataManager.shared
    @StateObject private var authManager = AppleAuthManager.shared

    var body: some View {
        NavigationView {
            List {
                // MARK: - Account
                Section(header: Text("Account")) {
                    if authManager.isSignedIn {
                        HStack {
                            Label("Signed in as", systemImage: "person.fill")
                            Spacer()
                            Text(authManager.displayName ?? "User")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { _ in
                                authManager.startSignInWithAppleFlow()
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 45)
                        .cornerRadius(8)
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Bible Study Tools
                Section(header: Text("Bible Study")) {
                    NavigationLink(destination: BookmarkView()) {
                        Label("Bookmarks", systemImage: "bookmark")
                    }

                    NavigationLink(destination: NotesView(reference: VerseReference(book: "", chapter: 1, verse: 1))) {
                        Label("Notes", systemImage: "note.text")
                    }
                    
                    NavigationLink(destination: HighlightedVersesView()) {
                        Label("Highlights", systemImage: "highlighter")
                    }
                }

                // MARK: - Fun & Games
                Section(header: Text("Fun & Games")) {
                    NavigationLink(destination: QuizSplashView()) {
                        Label("Who Said That?! Quiz", systemImage: "gamecontroller.fill")
                    }

                    NavigationLink(destination: LeaderboardView()) {
                        Label("Leaderboard", systemImage: "list.number")
                    }
                }

                // MARK: - About the App
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutView()) {
                        Label("About This App", systemImage: "info.circle")
                    }

                    NavigationLink(destination: CreditsView()) {
                        Label("Credits", systemImage: "person.2")
                    }

                    Link(destination: URL(string: "https://docs.google.com/document/d/19wITcvOSlMepW2D1hXNi4Uf8LS4PrqU7/edit")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "lock.shield")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }

                // MARK: - App Settings
                Section(header: Text("App")) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $authManager.needsUsernamePrompt) {
                if let uid = authManager.pendingUserID {
                    UsernamePromptView(userID: uid)
                } else {
                    UsernamePromptView()
                }
            }
        }
    }
}
