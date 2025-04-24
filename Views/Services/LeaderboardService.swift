//
//  LeaderboardService.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import Foundation
import FirebaseFirestore

struct QuizScoreEntry: Identifiable {
    let id: String
    let userID: String
    let score: Int
    let timestamp: Date
}

class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()
    
    private let db = Firestore.firestore()
    private let collection = "quizScores"
    
    @Published var topScores: [QuizScoreEntry] = []

    func fetchTopScores(quizType: String = "WhoSaidThat", limit: Int = 10) {
        db.collection(collection)
            .whereField("quizType", isEqualTo: quizType)
            .order(by: "score", descending: true)
            .order(by: "timestamp", descending: false)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch leaderboard: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No scores found.")
                    return
                }

                self.topScores = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let userID = data["userID"] as? String,
                        let score = data["score"] as? Int,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }

                    return QuizScoreEntry(
                        id: doc.documentID,
                        userID: userID,
                        score: score,
                        timestamp: timestamp.dateValue()
                    )
                }
                
                print("✅ Top scores fetched: \(self.topScores.count)")
            }
    }
}
