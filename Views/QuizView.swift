//
//  QuizView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import UIKit

struct QuizView: View {
    @State private var questions = QuizData.sampleQuestions.shuffled().prefix(10).map { $0 }
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false
    @State private var score = 0
    @State private var quizFinished = false
    @State private var timerProgress: CGFloat = 1.0
    @State private var timeRemaining = 10.0
    @State private var timer: Timer? = nil
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    if quizFinished {
                        QuizResultView(score: score, totalQuestions: questions.count)
                            .frame(maxWidth: .infinity)
                            .glassCard()
                    } else {
                        VStack(spacing: 20) {
                            Text("Who Said That?!")
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                        // Question Progress Indicator
                        HStack {
                            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            // Live Score Ticker
                            Text("Score: \(score)")
                                .font(.headline)
                        }

                        // Progress Bar
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
                                    .frame(width: geometry.size.width * (CGFloat(currentQuestionIndex) / CGFloat(max(questions.count - 1, 1))), height: 8)
                            }
                        }
                        .frame(height: 8)

                        // Timer Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 10)

                                Capsule()
                                    .fill(timerProgress > 0.3 ? Color.green : Color.red)
                                    .frame(width: geometry.size.width * timerProgress, height: 10)
                                    .animation(.linear(duration: 0.1), value: timerProgress)
                            }
                        }
                        .frame(height: 10)

                        Text(questions[currentQuestionIndex].quote)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .padding(.horizontal)

                        VStack(spacing: 14) {
                            ForEach(questions[currentQuestionIndex].shuffledAnswers, id: \.self) { answer in
                                Button(action: {
                                    checkAnswer(answer)
                                }) {
                                    Text(answer)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(
                                            selectedAnswer == answer ?
                                                (answer == questions[currentQuestionIndex].correctAnswer ?
                                                 LinearGradient(colors: [Color.green.opacity(0.95), Color.green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                 : LinearGradient(colors: [Color.red.opacity(0.95), Color.orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                : LinearGradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .cornerRadius(14)
                                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
                                }
                                .disabled(selectedAnswer != nil)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .glassCard()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 80)
        }
        }
        .safeAreaInset(edge: .bottom) {
            if !quizFinished && selectedAnswer != nil {
                VStack {
                    Button(action: nextQuestion) {
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
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func checkAnswer(_ answer: String) {
        // Only process if we haven't already selected an answer
        guard selectedAnswer == nil else { return }
        
        selectedAnswer = answer
        timer?.invalidate()

        if answer == questions[currentQuestionIndex].correctAnswer {
            score += 1
            giveHaptic(.success)
        } else {
            giveHaptic(.error)
        }
    }

    private func nextQuestion() {
        selectedAnswer = nil
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            resetTimer()
        } else {
            timer?.invalidate()
            quizFinished = true
            
            // Log the score when quiz is finished
            if let userID = UserDefaults.standard.string(forKey: "userID") {
                QuizScoreLogger.shared.logScore(userID: userID, score: score, quizType: "WhoSaidThat")
            }
        }
    }

    private func giveHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    private func startTimer() {
        timerProgress = 1.0
        timeRemaining = 10.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            timerProgress = max(0, timeRemaining / 10.0)
            
            if timeRemaining <= 0 {
                timer?.invalidate()
                giveHaptic(.error)
                
                // Handle timeout
                if selectedAnswer == nil {
                    selectedAnswer = "Timeout"
                    
                    // Move to next question after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        nextQuestion()
                    }
                }
            }
        }
    }

    private func resetTimer() {
        timer?.invalidate()
        startTimer()
    }
    
    // Reset the quiz to play again
    func resetQuiz() {
        questions = QuizData.sampleQuestions.shuffled().prefix(10).map { $0 }
        currentQuestionIndex = 0
        selectedAnswer = nil
        score = 0
        quizFinished = false
        resetTimer()
    }
}
