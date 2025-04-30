//
//  LeaderboardView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LeaderboardEntry: Identifiable {
    var id: String { userID }
    let userID: String
    let score: Int
    let username: String?
}

struct LeaderboardView: View {
    @State private var topScores: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let currentUserID = Auth.auth().currentUser?.uid

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    ProgressView("Loading Leaderboard...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = errorMessage {
                    Text("❌ \(errorMessage)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if topScores.isEmpty {
                    Text("No scores yet.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(topScores.indices, id: \.self) { index in
                        let entry = topScores[index]
                        let isCurrentUser = entry.userID == currentUserID

                        HStack {
                            Text("#\(index + 1)")
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            VStack(alignment: .leading) {
                                Text(entry.username ?? "User \(entry.userID.prefix(6))")
                                    .font(.headline)
                                    .foregroundColor(isCurrentUser ? .blue : .primary)

                                Text("Score: \(entry.score)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if isCurrentUser {
                                Text("You")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(5)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(isCurrentUser ? Color.blue.opacity(0.05) : Color.clear)
                    }
                }
            }
            .navigationTitle("Top Scores")
            .onAppear {
                fetchTopScores()
            }
        }
    }

    func fetchTopScores() {
        let db = Firestore.firestore()
        isLoading = true
        errorMessage = nil

        db.collection("quizScores")
            .order(by: "score", descending: true)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                var results: [LeaderboardEntry] = []
                let group = DispatchGroup()

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    let userID = data["userID"] as? String ?? "unknown"
                    let score = data["score"] as? Int ?? 0

                    group.enter()
                    db.collection("users").document(userID).getDocument { userDoc, _ in
                        let userData = userDoc?.data()
                        let username = userData?["username"] as? String ??
                                       userData?["displayName"] as? String
                        results.append(LeaderboardEntry(userID: userID, score: score, username: username))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.topScores = results
                    self.isLoading = false
                }
            }
    }
}
