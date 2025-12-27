// QuizGameSplitView.swift
// Split view for the "Who Said That?!" quiz, optimized for iPad

import SwiftUI

struct QuizGameSplitView: View {
    @ObservedObject var viewModel: QuizGameViewModel
    @Environment(\.horizontalSizeClass) private var horizontalClass

    var body: some View {
        // Show split view on iPad or large screens, fallback to single-column otherwise
        if horizontalClass == .regular {
            NavigationSplitView {
                QuizSidebar(viewModel: viewModel)
            } content: {
                QuizQuestionPanel(viewModel: viewModel)
            } detail: {
                QuizDetailPanel(viewModel: viewModel)
            }
        } else {
            // Fallback to regular single-column view
            QuizQuestionPanel(viewModel: viewModel)
        }
    }
}

struct QuizSidebar: View {
    @ObservedObject var viewModel: QuizGameViewModel
    var body: some View {
        VStack(spacing: 40) {
            Text("Quiz Progress")
                .font(.title2)
                .bold()
            Text("Score: \(viewModel.score)")
                .font(.title3)
            ProgressView(value: Double(viewModel.currentQuestionIndex), total: Double(viewModel.questions.count))
                .progressViewStyle(.linear)
                .padding(.vertical, 12)
            Spacer()
        }
        .padding()
    }
}

struct QuizQuestionPanel: View {
    @ObservedObject var viewModel: QuizGameViewModel
    var body: some View {
        Group {
            if let question = viewModel.currentQuestion {
                VStack(alignment: .leading, spacing: 32) {
                    Text(question.quote)
                        .font(.title)
                        .bold()
                        .padding(.top, 40)
                    ForEach(question.options.indices, id: \.self) { index in
                        Button(action: { viewModel.selectOption(index) }) {
                            HStack {
                                Text(question.options[index])
                                    .font(.headline)
                                    .padding()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .background(buttonBackground(for: index, in: viewModel))
                            .cornerRadius(14)
                        }
                        .disabled(viewModel.selectedOptionIndex != nil)
                    }
                    ProgressView(value: viewModel.timerProgress)
                        .progressViewStyle(.linear)
                    Spacer()
                }
                .padding(.horizontal, 32)
            } else {
                Text("No Question")
            }
        }
    }
    private func buttonBackground(for index: Int, in vm: QuizGameViewModel) -> Color {
        if let selected = vm.selectedOptionIndex {
            if selected == index {
                return index == vm.currentQuestion?.correctIndex ? Color.green.opacity(0.6) : Color.red.opacity(0.6)
            }
        }
        return Color(.secondarySystemBackground)
    }
}

struct QuizDetailPanel: View {
    @ObservedObject var viewModel: QuizGameViewModel
    var body: some View {
        if let question = viewModel.currentQuestion {
            VStack(spacing: 24) {
                Text("Reference")
                    .font(.headline)
                Text(question.reference)
                    .font(.title3)
                Spacer()
            }
            .padding()
        } else {
            Text("Select a question.")
        }
    }
}

#Preview {
    QuizGameSplitView(viewModel: QuizGameViewModel())
}
