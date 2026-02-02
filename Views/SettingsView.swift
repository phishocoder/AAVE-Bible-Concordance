//
//  SettingsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/6/25.
//
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel.shared
    @StateObject private var readingProgress = ReadingProgressService.shared
    @StateObject private var preferences = UserProfilePreferences.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAbout = false
    @AppStorage("lockScreenDailyVerseEnabled") private var lockScreenDailyVerseEnabled = false
    @AppStorage("lockScreenJesusSaidEnabled") private var lockScreenJesusSaidEnabled = false
    @AppStorage("lockScreenVerseVersion") private var lockScreenVerseVersion = VerseVersion.aave.rawValue
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    appearanceCard
                    readingCard
                    contentCard
                    onboardingCard
                    savedContentCard
                    notificationsCard
                    lockScreenCard
                    aboutCard
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .scrollIndicators(.hidden)
            .glassBackground()
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .applyGlassToolbar()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }

    private var appearanceCard: some View {
        SettingsSection(title: "Appearance") {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Theme", selection: $viewModel.appearanceMode) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Font Family")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Picker("Font", selection: $viewModel.fontFamily) {
                        ForEach(viewModel.availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    .pickerStyle(.menu)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Text Size: \(Int(viewModel.fontSize))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Home Screen Tagline")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Picker("Tagline", selection: $viewModel.tagline) {
                        ForEach(viewModel.availableTaglines, id: \.self) { tagline in
                            Text(tagline).tag(tagline)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    private var contentCard: some View {
        SettingsSection(title: "Content") {
            Toggle(isOn: $viewModel.showCommentary) {
                Label("Show Commentary", systemImage: "text.book.closed")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Translation")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Picker("Preferred Translation", selection: $viewModel.preferredTranslation) {
                    Text("AAVE").tag("AAVE")
                    Text("NET").tag("NET")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var readingCard: some View {
        SettingsSection(title: "Reading") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Goal: \(readingProgress.dailyGoalVerses) verses")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Slider(
                    value: Binding(
                        get: { Double(readingProgress.dailyGoalVerses) },
                        set: { readingProgress.dailyGoalVerses = Int($0) }
                    ),
                    in: 1...50,
                    step: 1
                )
            }
#if DEBUG
            NavigationLink(destination: ReadingProgressDebugView()) {
                SettingsNavigationRow(icon: "ladybug", tint: .pink, title: "Reading Progress Debug")
            }
#endif
        }
    }

    private var savedContentCard: some View {
        SettingsSection(title: "Saved Content") {
            NavigationLink {
                BookmarkView()
            } label: {
                SettingsNavigationRow(icon: "bookmark.fill", tint: .orange, title: "Bookmarks")
            }

            NavigationLink(destination: HighlightedVersesView()) {
                SettingsNavigationRow(icon: "highlighter", tint: .yellow, title: "Highlights")
            }
        }
    }

    private var notificationsCard: some View {
        SettingsSection(title: "Notifications") {
            NavigationLink(destination: NotificationSettingsView()) {
                SettingsNavigationRow(icon: "bell.fill", tint: .blue, title: "Notifications")
            }
        }
    }

    private var lockScreenCard: some View {
        SettingsSection(title: "Lock Screen") {
            VStack(alignment: .leading, spacing: 12) {
                if #available(iOS 16.1, *) {
                    Toggle(isOn: $lockScreenDailyVerseEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lock Screen: Daily Verse")
                                .fontWeight(.medium)
                            Text("Shows one daily verse on your Lock Screen. Tap to open.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: lockScreenDailyVerseEnabled) { _, newValue in
                        if newValue {
                            print("LA-DEBUG toggle ON")
                        } else {
                            print("LA-DEBUG toggle OFF")
                        }

                        if #available(iOS 16.1, *) {
                            if newValue {
                                debugDailyVerseLiveActivities("toggle-on-before-refresh")
                            }
                        }

                        DailyVerseLiveActivityCoordinator.setEnabled(newValue)

                        if #available(iOS 16.1, *) {
                            if newValue {
                                debugDailyVerseLiveActivities("toggle-on-after-refresh")
                            } else {
                                debugDailyVerseLiveActivities("toggle-off-after-end")
                            }
                        }
                    }

                    Toggle(isOn: $lockScreenJesusSaidEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Jesus Said Mode")
                                .fontWeight(.medium)
                            Text("Only shows verses where Jesus is speaking.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: lockScreenJesusSaidEnabled) { _, _ in
                        DailyVerseLiveActivityCoordinator.refreshIfEnabled()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lock Screen Verse Version")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Picker("Lock Screen Verse Version", selection: $lockScreenVerseVersion) {
                            ForEach(VerseVersion.allCases, id: \.rawValue) { version in
                                Text(version.label).tag(version.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .onChange(of: lockScreenVerseVersion) { _, _ in
                        DailyVerseLiveActivityCoordinator.refreshIfEnabled()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lock Screen: Daily Verse")
                            .fontWeight(.medium)
                        Text("Requires iOS 16.1 or later.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .opacity(0.6)
                }
            }
        }
    }

    private var aboutCard: some View {
        SettingsSection(title: "Support") {
            Button(action: { showingAbout = true }) {
                SettingsNavigationRow(icon: "info.circle", tint: .indigo, title: "About")
            }
        }
    }

    private var onboardingCard: some View {
        SettingsSection(title: "Onboarding") {
            Button(action: {
                preferences.resetOnboarding()
                NotificationCenter.default.post(name: Notification.Name("ShowOnboarding"), object: nil)
            }) {
                SettingsNavigationRow(icon: "arrow.counterclockwise", tint: .purple, title: "Reset Onboarding")
            }
        }
    }
}

private struct SettingsSection<Content: View>: View {
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

private struct SettingsNavigationRow: View {
    let icon: String
    let tint: Color
    let title: String
    var trailingSymbol: String = "chevron.right"
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let fill = colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.65)
        let stroke = colorScheme == .dark ? 0.08 : 0.25

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
                        .foregroundColor(.white)
                        .font(.title3)
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
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(stroke), lineWidth: 1)
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
