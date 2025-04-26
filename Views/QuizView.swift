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
        NavigationView {
            VStack(spacing: 20) {
                if quizFinished {
                    QuizResultView(score: score, totalQuestions: questions.count)
                } else {
                    VStack(spacing: 10) {
                        Text("Who Said That?!")
                            .font(.title)
                            .bold()
                        
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
                        .padding(.horizontal)
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 6)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                
                                Rectangle()
                                    .frame(width: geometry.size.width * (CGFloat(currentQuestionIndex) / CGFloat(questions.count - 1)), height: 6)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal)
                        
                        // Timer Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 8)
                                    .opacity(0.3)
                                    .foregroundColor(.gray)
                                
                                Rectangle()
                                    .frame(width: geometry.size.width * timerProgress, height: 8)
                                    .foregroundColor(timerProgress > 0.3 ? .green : .red)
                                    .animation(.linear(duration: 0.1), value: timerProgress)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                        
                        Text(questions[currentQuestionIndex].quote)
                            .font(.title3)
                            .padding()
                            .multilineTextAlignment(.center)
                        
                        ForEach(questions[currentQuestionIndex].shuffledAnswers, id: \.self) { answer in
                            Button(action: {
                                checkAnswer(answer)
                            }) {
                                Text(answer)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedAnswer == answer ? (answer == questions[currentQuestionIndex].correctAnswer ? Color.green : Color.red) : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedAnswer != nil)
                        }
                    }
                    .padding()

                    if selectedAnswer != nil {
                        Button("Next") {
                            nextQuestion()
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Quiz")
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
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
