import Foundation

/// Legacy compatibility wrapper so any existing code that still references
/// `QuizData.sampleQuestions` continues to work. Internally it now fetches
/// questions from the shared repository to ensure consistency.
struct QuizData {
    static var sampleQuestions: [QuizQuestion] {
        QuizQuestionRepository.shared.fetchRandomQuestions(count: 10)
    }
    
    static func sessionQuestions(count: Int = 10) -> [QuizQuestion] {
        QuizQuestionRepository.shared.fetchRandomQuestions(count: count)
    }
}
