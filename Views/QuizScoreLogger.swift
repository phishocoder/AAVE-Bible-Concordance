//
//  QuizScoreLogger.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import Foundation
import FirebaseFirestore

class QuizScoreLogger {
    static let shared = QuizScoreLogger()
    
    private let db = Firestore.firestore()
    private let collection = "quizScores"

    func logScore(userID: String, score: Int, quizType: String = "WhoSaidThat", completion: ((Result<Void, Error>) -> Void)? = nil) {
        let data: [String: Any] = [
            "userID": userID,
            "score": score,
            "quizType": quizType,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection(collection).addDocument(data: data) { error in
            if let error = error {
                print("❌ Failed to log quiz score: \(error.localizedDescription)")
                completion?(.failure(error))
            } else {
                print("✅ Quiz score logged for user: \(userID)")
                completion?(.success(()))
            }
        }
    }
}
