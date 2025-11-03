//
//  QuizQuestionModel.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let quote: String      // The Bible quote
    let correctAnswer: String // The correct speaker
    let wrongAnswers: [String] // 3 wrong answer choices
    let shuffledAnswers: [String]
    
    init(quote: String, correctAnswer: String, wrongAnswers: [String]) {
        self.quote = quote
        self.correctAnswer = correctAnswer
        self.wrongAnswers = wrongAnswers
        
        // Shuffle answers once during initialization
        let allAnswers = wrongAnswers + [correctAnswer]
        self.shuffledAnswers = allAnswers.shuffled()
    }
}
