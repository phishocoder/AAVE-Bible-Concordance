//
//  SplashView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/18/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentIndex = 0
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenWhatsNewVersion = ""
    private let whatsNewRelease = "1.6-june-reader-update"
    
    let taglines = [
        ("God's Word. Our Voice.", "🗣️"),
        ("Scripture, but make it real.", "💯"),
        ("The Bible, the way we talk.", "🤝"),
        ("Bridging the Gap Between The Word & The Culture.", "🌉"),
        ("From Genesis to Revelation, No Cap.", "📖")
    ]

    let whatsNewItems = [
        ("🔎", "Better Scripture search for references, exact phrases, and important words"),
        ("🛡️", "Grace Pass now clearly protects your streak automatically after one missed day"),
        ("⚡️", "Faster, smoother chapter reading with nearby chapters prepared in advance"),
        ("📖", "More responsive verse selection, commentary, comparison, and sharing")
    ]
    
    let timer = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let background = GlassTheme.backgroundGradient(for: colorScheme)

        ZStack {
            background
                .ignoresSafeArea()

            // Soft ambient glow
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.18 : 0.10))
                    .frame(width: 520, height: 520)
                    .blur(radius: 70)
                    .offset(x: -140, y: -220)

                Circle()
                    .fill(Color.purple.opacity(colorScheme == .dark ? 0.16 : 0.08))
                    .frame(width: 480, height: 480)
                    .blur(radius: 70)
                    .offset(x: 170, y: -130)

                Circle()
                    .fill(Color.orange.opacity(colorScheme == .dark ? 0.10 : 0.06))
                    .frame(width: 520, height: 520)
                    .blur(radius: 80)
                    .offset(x: 0, y: 320)
            }
            .allowsHitTesting(false)

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 14) {
                    GlassLogo()
                        .shadow(color: Color.white.opacity(colorScheme == .dark ? 0.18 : 0.10), radius: 18, x: 0, y: 10)

                    Text("Bible Concordance")
                        .font(AAVETypography.launchSubtitle)
                        .foregroundStyle(.primary)
                        .opacity(colorScheme == .dark ? 0.92 : 0.85)
                }

                VStack(spacing: 12) {
                    Text(taglines[currentIndex].1)
                        .font(.system(size: 44))
                        .scaleEffect(1.0)
                        .accessibilityHidden(true)

                    Text(taglines[currentIndex].0)
                        .font(AAVETypography.tagline)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .id(currentIndex)
                }
                .padding(.horizontal, 28)

                if lastSeenWhatsNewVersion != whatsNewRelease {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What’s new in version 1.6")
                            .font(AAVETypography.sectionTitle)
                            .foregroundStyle(.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(whatsNewItems, id: \.0) { item in
                                HStack(alignment: .top, spacing: 10) {
                                    Text(item.0)
                                        .font(.system(size: 18))
                                    Text(item.1)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary.opacity(0.9))
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.22))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.18), lineWidth: 1)
                    )
                    .padding(.horizontal, 28)
                }

                Spacer()

                VStack(spacing: 14) {
                    if appState.isInitialLoadComplete {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                if lastSeenWhatsNewVersion != whatsNewRelease {
                                    lastSeenWhatsNewVersion = whatsNewRelease
                                }
                                appState.continueToApp()
                            }
                        }) {
                            Text("Start Reading")
                                .font(AAVETypography.button)
                                .foregroundStyle(.primary.opacity(0.85))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    } else {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(.white.opacity(colorScheme == .dark ? 0.85 : 0.65))
                            Text("Loading…")
                                .font(AAVETypography.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 2)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .transition(.opacity)
        .onReceive(timer) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                currentIndex = (currentIndex + 1) % taglines.count
            }
        }
    }
}

private struct GlassLogo: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            Text("A")
                .foregroundColor(.red)
            Text("A")
                .foregroundColor(Color(UIColor.aaveLogoSecondA))
                .overlay(
                    Text("A")
                        .foregroundColor(Color(UIColor.aaveLogoSecondAOutline))
                        .opacity(colorScheme == .dark ? 1.0 : 0.0)
                )
            Text("V")
                .foregroundColor(.yellow)
            Text("E")
                .foregroundColor(.green)
        }
        .font(AAVETypography.logo)
        .shadow(color: Color.white.opacity(colorScheme == .dark ? 0.12 : 0.08), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
