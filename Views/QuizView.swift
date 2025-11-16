//
//  QuizView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import UIKit

struct QuizView: View {
    @StateObject private var viewModel = QuizGameViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.quizFinished {
                    QuizResultView(score: viewModel.score, totalQuestions: viewModel.questions.count)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                    
                    Button("Play Again") {
                        viewModel.startNewGame()
                    }
                    .buttonStyle(.borderedProminent)
                } else if let question = viewModel.currentQuestion {
                    quizCard(for: question)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 80)
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.quizFinished, viewModel.selectedOptionIndex != nil {
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
    }
    
    @ViewBuilder
    private func quizCard(for question: QuizQuestion) -> some View {
        VStack(spacing: 20) {
            Text("Who Said That?!")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Score: \(viewModel.score)")
                    .font(.headline)
            }
            
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
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(viewModel.timerProgress > 0.3 ? Color.green : Color.red)
                        .frame(width: geometry.size.width * viewModel.timerProgress, height: 10)
                        .animation(.linear(duration: 0.1), value: viewModel.timerProgress)
                }
            }
            .frame(height: 10)
            
            Text(question.quote)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.horizontal)
            
            VStack(spacing: 14) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
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
    
    private var progressFraction: CGFloat {
        guard viewModel.questions.count > 1 else { return 0 }
        return CGFloat(viewModel.currentQuestionIndex) / CGFloat(max(viewModel.questions.count - 1, 1))
    }
    
    private func answerBackground(for index: Int, question: QuizQuestion) -> LinearGradient {
        guard let selected = viewModel.selectedOptionIndex else {
            return LinearGradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
            return LinearGradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
