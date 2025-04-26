//
//  QuizSplashView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI

struct QuizSplashView: View {
    @State private var startQuiz = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Who Said That?!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            Text("Test your Bible knowledge!\n\nYou’ll get 10 random quotes.\nGuess who said each one — before the timer runs out!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                Label("⏳ 10 seconds per question", systemImage: "clock")
                Label("✅ Answer fast to rack up your score", systemImage: "checkmark.circle")
                Label("🏆 Earn a badge based on your final score", systemImage: "star.circle")
                Label("⚡ Replay to beat your best!", systemImage: "arrow.clockwise.circle")
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                startQuiz = true
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
        .navigationDestination(isPresented: $startQuiz) {
            QuizView()
        }
    }
}
