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

    func fetchBestScore(userID: String, quizType: String = "WhoSaidThat", completion: @escaping (Int?) -> Void) {
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("quizType", isEqualTo: quizType)
            .getDocuments { snapshot, error in
                if let error {
                    print("❌ Failed to fetch best score: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                let scores = snapshot?.documents.compactMap { $0.data()["score"] as? Int } ?? []
                completion(scores.max())
            }
    }
}
