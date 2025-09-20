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
    @State private var opacity = 0.0
    @Environment(\.colorScheme) var colorScheme
    
    let taglines = [
        ("God's Word. Our Voice.", "🗣️"),
        ("Scripture, but make it real.", "💯"),
        ("The Bible, the way we talk.", "🤝"),
        ("Bridging the Gap Between The Word & The Culture.", "🌉"),
        ("From Genesis to Revelation, No Cap.", "📖")
    ]
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let background = GlassTheme.backgroundGradient(for: colorScheme)

        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    GlassLogo()

                    Text("Bible Concordance")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                }

                VStack(spacing: 12) {
                    Text(taglines[currentIndex].0)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                        .id(currentIndex)

                    Text(taglines[currentIndex].1)
                        .font(.system(size: 44))
                }

                Spacer()

                VStack(spacing: 20) {
                    ProgressView(value: appState.loadingProgress)
                        .progressViewStyle(.linear)
                        .tint(.white.opacity(0.9))
                        .padding(.horizontal, 32)

                    if appState.isInitialLoadComplete {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                appState.continueToApp()
                            }
                        }) {
                            Text("Start Reading")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color.blue.opacity(0.95), Color.indigo.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
            }
        }
        .onReceive(timer) { _ in
            withAnimation {
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
        .font(.system(size: 72, weight: .bold, design: .rounded))
    }
}

#Preview {
    SplashView()
        .environmentObject(AppState())
}
