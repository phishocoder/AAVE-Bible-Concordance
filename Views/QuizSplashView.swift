//
//  QuizSplashView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import UIKit

struct QuizSplashView: View {
    @State private var shouldStartQuiz = false
    @State private var isBeginPressed = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text("Who Said That?!")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("Test your memory of Scripture. Stay sharp, stay rooted, and keep your daily rhythm.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 10) {
                        statChip(title: "10", subtitle: "Questions", symbol: "list.number")
                        statChip(title: "15s", subtitle: "Per Verse", symbol: "clock")
                        statChip(title: "All", subtitle: "Scripture", symbol: "book.closed")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("No trick questions. Quotes come from Scripture.", systemImage: "checkmark.seal")
                        Label("Read carefully, then choose who said it.", systemImage: "eye")
                        Label("Track your best score and keep improving.", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: beginQuiz) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                            Text("Begin")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [Color.indigo.opacity(0.95), Color.blue.opacity(0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 8)
                        .scaleEffect(isBeginPressed ? 0.98 : 1.0)
                        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isBeginPressed)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .glassCard()
                .frame(maxWidth: 720)
                .frame(minHeight: proxy.size.height, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(GlassTheme.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .applyGlassToolbar()
        .navigationDestination(isPresented: $shouldStartQuiz) {
            QuizView(showIntroCountdown: true)
        }
    }

    private func statChip(title: String, subtitle: String, symbol: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline.weight(.semibold))
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func beginQuiz() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        isBeginPressed = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            isBeginPressed = false
            shouldStartQuiz = true
        }
    }
}

#Preview("Quiz Intro - iPhone SE") {
    NavigationStack {
        QuizSplashView()
    }
    .previewDevice("iPhone SE (3rd generation)")
}

#Preview("Quiz Intro - iPhone 15 Pro") {
    NavigationStack {
        QuizSplashView()
    }
    .previewDevice("iPhone 15 Pro")
}

#Preview("Quiz Intro - iPhone 15 Pro Max") {
    NavigationStack {
        QuizSplashView()
    }
    .previewDevice("iPhone 15 Pro Max")
}
