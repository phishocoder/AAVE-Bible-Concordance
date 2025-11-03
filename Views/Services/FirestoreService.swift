//
//  FirestoreService.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    func saveQuizScore(userID: String, score: Int, quizType: String) {
        let data: [String: Any] = [
            "userID": userID,
            "score": score,
            "quizType": quizType,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("quizScores").addDocument(data: data) { error in
            if let error = error {
                print("❌ Error saving quiz score: \(error.localizedDescription)")
            } else {
                print("✅ Quiz score saved to Firestore!")
            }
        }
    }
}
