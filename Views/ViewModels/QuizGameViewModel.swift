import SwiftUI
import Combine
import FirebaseAuth

/// Drives the "Who Said That?!" quiz so both Home and More tabs share the exact
/// same logic, question bank, and timing rules. Handles randomization & timer.
final class QuizGameViewModel: ObservableObject {
    @Published private(set) var questions: [QuizQuestion] = []
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published var selectedOptionIndex: Int? = nil
    @Published var quizFinished: Bool = false
    @Published var timerProgress: CGFloat = 1.0
    @Published var timeRemaining: Double = 15
    @Published private(set) var personalBestImproved: Bool = false
    @Published private(set) var previousBestScore: Int?
    
    let questionsPerSession = 10
    let timePerQuestion: Double = 15
    
    private let repository: QuizQuestionRepository
    private var timer: Timer?
    
    init(repository: QuizQuestionRepository = .shared, autostartTimer: Bool = true) {
        self.repository = repository
        startNewGame(autostartTimer: autostartTimer)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    func startNewGame() {
        startNewGame(autostartTimer: true)
    }
    
    func startNewGame(autostartTimer: Bool = true) {
        stopTimer()
        questions = repository.fetchRandomQuestions(count: questionsPerSession).map { question in
            // Shuffle options while tracking the new correct index
            let correctAnswer = question.options[question.correctIndex]
            let shuffledOptions = question.options.shuffled()
            let newCorrectIndex = shuffledOptions.firstIndex(of: correctAnswer) ?? 0
            
            return QuizQuestion(
                id: question.id,
                quote: question.quote,
                options: shuffledOptions,
                correctIndex: newCorrectIndex,
                reference: question.reference
            )
        }
        currentQuestionIndex = 0
        score = 0
        quizFinished = false
        selectedOptionIndex = nil
        personalBestImproved = false
        previousBestScore = nil
        timeRemaining = timePerQuestion
        timerProgress = 1.0
        if autostartTimer {
            startTimer()
        }
    }

    func beginSession() {
        guard !quizFinished, selectedOptionIndex == nil else { return }
        guard timer == nil else { return }
        startTimer()
    }
    
    func selectOption(_ index: Int) {
        guard selectedOptionIndex == nil, let question = currentQuestion else { return }
        selectedOptionIndex = index
        stopTimer()
        
        if index == question.correctIndex {
            score += 1
        }
    }
    
    func advance() {
        guard !quizFinished else { return }
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedOptionIndex = nil
            startTimer()
        } else {
            finishQuiz()
        }
    }
    
    func timeRanOut() {
        guard selectedOptionIndex == nil else { return }
        selectedOptionIndex = -1 // indicates timeout
        stopTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.advance()
        }
    }
    
    private func startTimer() {
        timeRemaining = timePerQuestion
        timerProgress = 1.0
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.timeRemaining -= 0.1
            self.timerProgress = max(0, self.timeRemaining / self.timePerQuestion)
            
            if self.timeRemaining <= 0 {
                self.timeRanOut()
            }
        }
    }
    
    private func finishQuiz() {
        stopTimer()
        quizFinished = true
        selectedOptionIndex = nil

        if score == questionsPerSession {
            Task { @MainActor in
                AchievementService.shared.unlock(.perfectQuizScore)
            }
        }
        
        if let userID = Auth.auth().currentUser?.uid {
            QuizScoreLogger.shared.fetchBestScore(userID: userID, quizType: "WhoSaidThat") { [weak self] bestScore in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.previousBestScore = bestScore
                    self.personalBestImproved = bestScore == nil || self.score > (bestScore ?? 0)
                    if let bestScore, self.score > bestScore {
                        Task { @MainActor in
                            NotificationManager.shared.scheduleMilestoneCelebration(.quizPersonalBest(score: self.score))
                        }
                    }
                }
            }
            QuizScoreLogger.shared.logScore(userID: userID, score: score, quizType: "WhoSaidThat")
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
