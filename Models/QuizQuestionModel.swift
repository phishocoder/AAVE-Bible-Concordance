//
//  QuizQuestionModel.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import Foundation

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let quote: String
    let options: [String]
    let correctIndex: Int
    let reference: String?
    
    init(
        id: UUID = UUID(),
        quote: String,
        options: [String],
        correctIndex: Int,
        reference: String? = nil
    ) {
        self.id = id
        self.quote = quote
        self.options = options
        self.correctIndex = correctIndex
        self.reference = reference
    }
}
