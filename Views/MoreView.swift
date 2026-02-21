import SwiftUI
import AuthenticationServices

struct MoreView: View {
    @State private var showingSettings = false
    @ObservedObject private var userDataManager = UserDataManager.shared
    @StateObject private var authManager = AppleAuthManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                accountCard
                
                sectionCard(title: "Bible Study") {
                    NavigationLink {
                        BookmarkView()
                    } label: {
                        MoreRow(icon: "bookmark.fill", tint: .orange, title: "Bookmarks")
                    }
                    NavigationLink {
                        NotesView()
                    } label: {
                        MoreRow(icon: "note.text", tint: .teal, title: "Notes")
                    }
                    NavigationLink {
                        AchievementsView()
                    } label: {
                        MoreRow(icon: "trophy.fill", tint: .yellow, title: "Achievements")
                    }
                    NavigationLink {
                        HighlightedVersesView()
                    } label: {
                        MoreRow(icon: "highlighter", tint: .yellow, title: "Highlights")
                    }
                }
                
                sectionCard(title: "Fun & Games") {
                    NavigationLink {
                        QuizSplashView()
                    } label: {
                        MoreRow(icon: "gamecontroller.fill", tint: .purple, title: "Who Said That?! Quiz")
                    }
                    NavigationLink {
                        LeaderboardView()
                    } label: {
                        MoreRow(icon: "list.number", tint: .pink, title: "Leaderboard")
                    }
                }
                
                sectionCard(title: "About") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        MoreRow(icon: "info.circle", tint: .blue, title: "About This App")
                    }
                    NavigationLink {
                        CreditsView()
                    } label: {
                        MoreRow(icon: "person.2", tint: .green, title: "Credits")
                    }
                    Link(destination: URL(string: "https://docs.google.com/document/d/19wITcvOSlMepW2D1hXNi4Uf8LS4PrqU7/edit")!) {
                        MoreRow(icon: "lock.shield", tint: .gray, title: "Privacy Policy", trailingSymbol: "arrow.up.right")
                    }
                }
                
                sectionCard(title: "App") {
                    Button(action: { showingSettings = true }) {
                        MoreRow(icon: "gearshape.fill", tint: .indigo, title: "Settings")
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 0)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .applyGlassToolbar()
        .glassBackground()
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
    
    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.title3)
                .fontWeight(.semibold)
            
            if authManager.isSignedIn {
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            LinearGradient(colors: [.teal.opacity(0.9), .blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Signed in as")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(authManager.displayName ?? "Friend")
                            .font(.headline)
                    }
                }
            } else {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        authManager.configureAppleRequest(request)
                    },
                    onCompletion: { result in
                        authManager.handleAuthorizationResult(result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .glassCard()
    }
    
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                content()
            }
        }
        .glassCard()
    }
}

private struct MoreRow: View {
    let icon: String
    let tint: Color
    let title: String
    var trailingSymbol: String = "chevron.right"
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let backgroundFill = colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.65)
        let strokeOpacity = colorScheme == .dark ? 0.08 : 0.25
        
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint.opacity(0.95), tint.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                )
            
            Text(title)
                .foregroundColor(.primary)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: trailingSymbol)
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
        )
    }
}
