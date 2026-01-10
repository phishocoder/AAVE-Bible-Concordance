import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferences = UserProfilePreferences.shared
    @StateObject private var readingProgress = ReadingProgressService.shared
    @StateObject private var authManager = AppleAuthManager.shared
    @State private var showingSignOutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileCard
                    streakCard
                    shortcutsCard
                    signOutCard
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .applyGlassToolbar()
            .glassBackground()
        }
        .alert("Sign Out?", isPresented: $showingSignOutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out") {
                authManager.signOut()
                dismiss()
            }
        } message: {
            Text("You can sign back in anytime. Your reading data stays on this device.")
        }
    }

    private var profileCard: some View {
        ProfileSection(title: "Account") {
            VStack(alignment: .leading, spacing: 16) {
                if authManager.isSignedIn {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        TextField("First name", text: $preferences.displayName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                    }

                    ProfileInfoRow(label: "Sign-in Method", value: "Sign in with Apple")
                    ProfileInfoRow(label: "Status", value: "Signed in")
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

                    ProfileInfoRow(label: "Status", value: "Signed out")
                }
            }
        }
    }

    private var streakCard: some View {
        ProfileSection(title: "Reading Streak") {
            VStack(alignment: .leading, spacing: 12) {
                ProfileInfoRow(
                    label: "Current Streak",
                    value: "\(readingProgress.currentStreak) day\(readingProgress.currentStreak == 1 ? "" : "s")"
                )

                ProfileInfoRow(
                    label: "Longest Streak",
                    value: "\(readingProgress.longestStreak) day\(readingProgress.longestStreak == 1 ? "" : "s")"
                )

                ProfileInfoRow(
                    label: "Today",
                    value: readingProgress.currentStreak > 0 ? "Done" : "Not yet"
                )
            }
        }
    }

    private var shortcutsCard: some View {
        ProfileSection(title: "Shortcuts") {
            VStack(spacing: 12) {
                NavigationLink {
                    AchievementsView()
                } label: {
                    ProfileNavRow(icon: "trophy.fill", tint: .yellow, title: "Achievements")
                }

                NavigationLink {
                    NotificationSettingsView()
                } label: {
                    ProfileNavRow(icon: "bell.fill", tint: .blue, title: "Notification Preferences")
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    ProfileNavRow(icon: "paintbrush.pointed.fill", tint: .purple, title: "Appearance & Tone")
                }
            }
        }
    }

    private var signOutCard: some View {
        ProfileSection(title: "Session") {
            Button(action: { showingSignOutConfirm = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.backward.circle")
                        .font(.title3)
                    Text("Sign Out")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .disabled(!authManager.isSignedIn)
            .opacity(authManager.isSignedIn ? 1 : 0.5)
        }
    }
}

private struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 16) {
                content
            }
        }
        .glassCard()
    }
}

private struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

private struct ProfileNavRow: View {
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

#Preview {
    ProfileView()
}
