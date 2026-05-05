import SwiftUI
import AuthenticationServices

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var preferences = UserProfilePreferences.shared
    @StateObject private var readingProgress = ReadingProgressService.shared
    @StateObject private var authManager = AppleAuthManager.shared
    @State private var showingSignOutConfirm = false
    @State private var showingDeleteConfirm = false
    @State private var showingDeleteSuccess = false
    @State private var showingDeleteError = false
    @State private var attemptedAutomaticReauthentication = false
    @State private var isSavingName = false
    @State private var isDeletingAccount = false
    @State private var deletionErrorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileCard
                    streakCard
                    shortcutsCard
                    signOutCard
                    deleteAccountCard
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
        .alert("Delete Account?", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete My Account", role: .destructive) {
                attemptedAutomaticReauthentication = false
                Task {
                    await beginAccountDeletion()
                }
            }
        } message: {
            Text(accountDeletionWarning)
        }
        .alert("Account Deleted", isPresented: $showingDeleteSuccess) {
            Button("OK") {
                finishSuccessfulAccountDeletion()
            }
        } message: {
            Text("Your account and associated app data have been deleted.")
        }
        .alert("Couldn’t Delete Account", isPresented: $showingDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deletionErrorMessage)
        }
    }

    private var accountDeletionWarning: String {
        """
        This will permanently delete your account and associated app data. This action cannot be undone.

        Deleted data includes your Firebase sign-in account, profile/display name, leaderboard identity, quiz scores, local bookmarks, highlights, notes, reading progress, streaks, and notification preferences.

        Apple may ask you to confirm your identity before deletion can finish.
        """
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
                            .onSubmit {
                                saveDisplayName()
                            }
                        Button(action: saveDisplayName) {
                            if isSavingName {
                                ProgressView()
                            } else {
                                Text("Save Display Name")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(preferences.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

                if readingProgress.currentStreak > 0 {
                    ProfileInfoRow(
                        label: "Grace Pass",
                        value: readingProgress.gracePassesRemaining > 0 ? "Available" : "Used"
                    )
                }
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

    private var deleteAccountCard: some View {
        ProfileSection(title: "Account Management") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Delete your account and remove your associated app data from this device and Firebase.")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    HStack(spacing: 12) {
                        if isDeletingAccount {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Image(systemName: "trash")
                                .font(.title3)
                        }
                        Text("Delete Account")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(!authManager.isSignedIn || isDeletingAccount)
                .opacity(authManager.isSignedIn ? 1 : 0.5)
            }
        }
    }

    private func saveDisplayName() {
        let trimmed = preferences.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSavingName = true
        authManager.updateDisplayName(trimmed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isSavingName = false
        }
    }

    private func beginAccountDeletion() async {
        isDeletingAccount = true
        defer { isDeletingAccount = false }

        do {
            try await AccountDeletionService.shared.deleteCurrentUserAccount()
            showingDeleteSuccess = true
        } catch let error as AccountDeletionService.AccountDeletionError {
            handleDeletionError(error, allowAutomaticReauthentication: true)
        } catch {
            handleDeletionError(.unknown(error.localizedDescription), allowAutomaticReauthentication: true)
        }
    }

    private func reauthenticateAndRetryDeletion() {
        isDeletingAccount = true
        authManager.reauthenticateForSensitiveAction { result in
            switch result {
            case .success:
                Task {
                    await beginAccountDeletion()
                }
            case .failure(let error):
                isDeletingAccount = false
                handleDeletionError(.unknown(error.localizedDescription), allowAutomaticReauthentication: false)
            }
        }
    }

    private func handleDeletionError(
        _ error: AccountDeletionService.AccountDeletionError,
        allowAutomaticReauthentication: Bool
    ) {
        switch error {
        case .requiresRecentLogin where allowAutomaticReauthentication && !attemptedAutomaticReauthentication:
            attemptedAutomaticReauthentication = true
            reauthenticateAndRetryDeletion()
        case .requiresRecentLogin:
            deletionErrorMessage = "Apple couldn’t confirm this account for deletion. Try Delete Account again and complete the Apple confirmation."
            showingDeleteError = true
        default:
            deletionErrorMessage = error.errorDescription ?? "We couldn’t delete the account."
            showingDeleteError = true
        }
    }

    private func finishSuccessfulAccountDeletion() {
        dismiss()
        NotificationCenter.default.post(name: Notification.Name("ShowOnboarding"), object: nil)
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
