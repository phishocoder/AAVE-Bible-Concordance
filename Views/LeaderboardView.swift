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

struct UserScoreSummary {
    let bestScore: Int?
    let latestScore: Int?
    let gamesPlayed: Int
}

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @ObservedObject private var readingProgress = ReadingProgressService.shared
    private let currentUserID = Auth.auth().currentUser?.uid

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.entries.isEmpty && viewModel.userSummary == nil {
                ProgressView("Loading progress...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                Section("Your Progress") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Growth over flexing. Keep showing up in the Word.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 10) {
                            scoreStatPill(
                                title: "Best",
                                value: statValue(viewModel.userSummary?.bestScore)
                            )
                            scoreStatPill(
                                title: "Latest",
                                value: statValue(viewModel.userSummary?.latestScore)
                            )
                            scoreStatPill(
                                title: "Streak",
                                value: "\(readingProgress.currentStreak)d"
                            )
                        }

                        Text("Games played: \(viewModel.userSummary?.gamesPlayed ?? 0)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .homeCard()
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Top Scores (Community)") {
                    if let errorMessage = viewModel.errorMessage {
                        Text("Couldn't load community scores: \(errorMessage)")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .homeCard()
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else if viewModel.entries.isEmpty {
                        Text("No community scores yet.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .homeCard()
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(viewModel.entries.indices, id: \.self) { index in
                            let entry = viewModel.entries[index]
                            leaderboardRow(for: entry, rank: index + 1)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("Leaderboard")
        .onAppear {
            viewModel.fetchLeaderboard(currentUserID: currentUserID)
        }
    }

    private func leaderboardRow(for entry: LeaderboardEntry, rank: Int) -> some View {
        let isCurrentUser = entry.userID == currentUserID
        return HStack {
            Text("#\(rank)")
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .homeCard()
        .overlay(alignment: .topLeading) {
            if isCurrentUser {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.blue.opacity(0.45), lineWidth: 1)
            }
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func statValue(_ value: Int?) -> String {
        guard let value else { return "--" }
        return "\(value)"
    }

    private func scoreStatPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.08))
        )
    }
}

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userSummary: UserScoreSummary?

    private let db = Firestore.firestore()

    func fetchLeaderboard(currentUserID: String?, limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        userSummary = nil

        var pendingRequests = currentUserID == nil ? 1 : 2

        func completeOneRequest() {
            pendingRequests -= 1
            if pendingRequests == 0 {
                self.isLoading = false
            }
        }

        db.collection("quizScores")
            .order(by: "score", descending: true)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        completeOneRequest()
                    }
                    return
                }

                let docs = snapshot?.documents ?? []
                if docs.isEmpty {
                    DispatchQueue.main.async {
                        self.entries = []
                        completeOneRequest()
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
                    completeOneRequest()
                }
            }

        guard let currentUserID else { return }

        db.collection("quizScores")
            .whereField("userID", isEqualTo: currentUserID)
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }
                if error != nil {
                    DispatchQueue.main.async {
                        self.userSummary = UserScoreSummary(bestScore: nil, latestScore: nil, gamesPlayed: 0)
                        completeOneRequest()
                    }
                    return
                }

                let docs = snapshot?.documents ?? []
                let scoredRuns: [(score: Int, timestamp: Date)] = docs.compactMap { doc in
                    let data = doc.data()
                    guard let score = data["score"] as? Int,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return (score: score, timestamp: timestamp.dateValue())
                }
                let scores = scoredRuns.map(\.score)
                let latest = scoredRuns.sorted { $0.timestamp > $1.timestamp }.first?.score
                let best = scores.max()

                DispatchQueue.main.async {
                    self.userSummary = UserScoreSummary(
                        bestScore: best,
                        latestScore: latest,
                        gamesPlayed: scores.count
                    )
                    completeOneRequest()
                }
            }
    }
}
