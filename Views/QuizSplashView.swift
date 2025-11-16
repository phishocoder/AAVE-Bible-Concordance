//
//  QuizSplashView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI

struct QuizSplashView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("Who Said That?!")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Test your Bible knowledge!\nYou'll get 10 random quotes. Beat the clock and flex your scripture memory.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Label("⏳ 15 seconds per question", systemImage: "clock")
                    Label("✅ Answer fast to rack up your score", systemImage: "checkmark.circle")
                    Label("🏆 Earn a badge based on your final score", systemImage: "star.circle")
                    Label("⚡ Replay to beat your best!", systemImage: "arrow.clockwise.circle")
                }
                .font(.subheadline)

                NavigationLink(destination: QuizView()) {
                    Text("Start Quiz")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.95), Color.indigo.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 10)
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .glassCard()
            .padding(.horizontal, 24)
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .applyGlassToolbar()
        }
        .glassBackground()
    }
}
