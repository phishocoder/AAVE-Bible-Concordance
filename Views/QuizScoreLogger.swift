//
//  QuizScoreLogger.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class QuizScoreLogger {
    static let shared = QuizScoreLogger()
    
    private let db = Firestore.firestore()
    private let collection = "quizScores"

    func logScore(userID: String, score: Int, quizType: String = "WhoSaidThat", completion: ((Result<Void, Error>) -> Void)? = nil) {
        let now = Date()
        let data: [String: Any?] = [
            "userID": userID,
            "score": score,
            "quizType": quizType,
            "timestamp": Timestamp(date: now),
            "leaderboardWeek": Self.leaderboardWeekKey(for: now),
            "leaderboardWeekStartAt": Timestamp(date: Self.startOfLeaderboardWeek(for: now)),
            "username": currentDisplayName()
        ]

        db.collection(collection).addDocument(data: data.compactMapValues { $0 }) { error in
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

    private func currentDisplayName() -> String? {
        let storedName = UserDefaults.standard.string(forKey: "displayName")?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let storedName, !storedName.isEmpty, !Self.isPlaceholderDisplayName(storedName) {
            return storedName
        }

        let authName = Auth.auth().currentUser?.displayName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let authName, !authName.isEmpty, !Self.isPlaceholderDisplayName(authName) {
            return authName
        }

        return nil
    }

    static func isPlaceholderDisplayName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }

        let pattern = #"^Reader\s\d{4}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    static func leaderboardWeekKey(for date: Date, calendar: Calendar = .current) -> String {
        let start = startOfLeaderboardWeek(for: date, calendar: calendar)
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: start)
    }

    static func startOfLeaderboardWeek(for date: Date, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }
}
