//
//  QuizView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import UIKit

struct QuizView: View {
    @StateObject private var viewModel: QuizGameViewModel
    private let showIntroCountdown: Bool
    @State private var countdownValue: Int
    @State private var showCountdownOverlay: Bool
    @State private var hasStartedCountdown = false

    init(showIntroCountdown: Bool = false) {
        self.showIntroCountdown = showIntroCountdown
        _viewModel = StateObject(wrappedValue: QuizGameViewModel(autostartTimer: !showIntroCountdown))
        _countdownValue = State(initialValue: showIntroCountdown ? 3 : 0)
        _showCountdownOverlay = State(initialValue: showIntroCountdown)
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.quizFinished {
                        QuizResultView(
                            score: viewModel.score,
                            totalQuestions: viewModel.questions.count,
                            personalBestImproved: viewModel.personalBestImproved,
                            previousBestScore: viewModel.previousBestScore,
                            onPlayAgain: viewModel.startNewGame
                        )
                            .frame(maxWidth: .infinity)
                            .glassCard()
                    } else if let question = viewModel.currentQuestion {
                        quizCard(for: question)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 80)
            }

            if showCountdownOverlay && !viewModel.quizFinished {
                countdownOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(2)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.quizFinished, viewModel.selectedOptionIndex != nil, !showCountdownOverlay {
                VStack {
                    Button(action: viewModel.advance) {
                        Text("Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.95), Color.cyan.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .sensoryFeedback(.selection, trigger: viewModel.selectedOptionIndex ?? -2)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .applyGlassToolbar()
        .glassBackground()
        .task {
            await runIntroCountdownIfNeeded()
        }
    }

    @ViewBuilder
    private func quizCard(for question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            quizHeader

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressFraction, height: 8)
                }
            }
            .frame(height: 8)
            
            Text(question.quote)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        viewModel.selectOption(index)
                    }) {
                        Text(option)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(answerBackground(for: index, question: question))
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(PressableQuizOptionStyle())
                    .disabled(viewModel.selectedOptionIndex != nil)
                }
            }
            .padding(.bottom, 12)
            
            if viewModel.selectedOptionIndex != nil, let reference = question.reference {
                Text(reference)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .glassCard()
    }

    private var quizHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Who Said That?!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(headerEncouragement)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 10) {
                timerRing
                Text("Score \(viewModel.score)")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 7)

            Circle()
                .trim(from: 0, to: viewModel.timerProgress)
                .stroke(
                    viewModel.timerProgress > 0.3 ? Color.green.opacity(0.95) : Color.red.opacity(0.95),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: viewModel.timerProgress)

            Text("\(Int(ceil(viewModel.timeRemaining)))")
                .font(.caption.weight(.bold))
        }
        .frame(width: 52, height: 52)
        .accessibilityLabel("Time remaining")
        .accessibilityValue("\(Int(ceil(viewModel.timeRemaining))) seconds")
    }

    private var headerEncouragement: String {
        let progress = Double(viewModel.currentQuestionIndex + 1) / Double(max(viewModel.questions.count, 1))
        switch progress {
        case 0..<0.34:
            return "Stay focused. Read it close."
        case 0.34..<0.67:
            return "You locked in. Keep that rhythm."
        default:
            return "Finish strong. Let the Word lead."
        }
    }

    private var countdownOverlay: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Center yourself")
                    .font(.headline)
                Text("Take a breath. Let's get in the Word.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Text(countdownValue > 0 ? "\(countdownValue)" : "Go")
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.top, 4)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }

    @MainActor
    private func runIntroCountdownIfNeeded() async {
        guard showIntroCountdown, !hasStartedCountdown else { return }
        hasStartedCountdown = true

        for second in stride(from: 3, through: 1, by: -1) {
            countdownValue = second
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            try? await Task.sleep(nanoseconds: 700_000_000)
        }

        countdownValue = 0
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        try? await Task.sleep(nanoseconds: 450_000_000)

        withAnimation(.easeInOut(duration: 0.25)) {
            showCountdownOverlay = false
        }
        viewModel.beginSession()
    }

    private var progressFraction: CGFloat {
        guard viewModel.questions.count > 1 else { return 0 }
        return CGFloat(viewModel.currentQuestionIndex) / CGFloat(max(viewModel.questions.count - 1, 1))
    }

    private func answerBackground(for index: Int, question: QuizQuestion) -> LinearGradient {
        guard let selected = viewModel.selectedOptionIndex else {
            return LinearGradient(colors: [Color.indigo.opacity(0.88), Color.blue.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }

        if selected == index {
            if index == question.correctIndex {
                return LinearGradient(colors: [Color.green.opacity(0.95), Color.green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            } else {
                return LinearGradient(colors: [Color.red.opacity(0.95), Color.orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        } else if index == question.correctIndex {
            return LinearGradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [Color.indigo.opacity(0.88), Color.blue.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct PressableQuizOptionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
