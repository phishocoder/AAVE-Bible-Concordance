//
//  LeaderboardView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LeaderboardEntry: Identifiable {
    var id: String { userID }
    let userID: String
    let score: Int
    let username: String?
}

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    private let currentUserID = Auth.auth().currentUser?.uid

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    ProgressView("Loading Leaderboard...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("❌ \(errorMessage)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.entries.isEmpty {
                    Text("No scores yet.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(viewModel.entries.indices, id: \.self) { index in
                        let entry = viewModel.entries[index]
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
                viewModel.fetchTopScores()
            }
        }
    }
}

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    func fetchTopScores(limit: Int = 10) {
        isLoading = true
        errorMessage = nil

        db.collection("quizScores")
            .order(by: "score", descending: true)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                    return
                }

                let docs = snapshot?.documents ?? []
                if docs.isEmpty {
                    DispatchQueue.main.async {
                        self.entries = []
                        self.isLoading = false
                    }
                    return
                }

                let results = docs.map { doc -> LeaderboardEntry in
                    let data = doc.data()
                    let userID = data["userID"] as? String ?? "unknown"
                    let score = data["score"] as? Int ?? 0
                    let username = data["username"] as? String
                    return LeaderboardEntry(userID: userID, score: score, username: username)
                }

                DispatchQueue.main.async {
                    self.entries = results
                    self.isLoading = false
                }
            }
    }
}
