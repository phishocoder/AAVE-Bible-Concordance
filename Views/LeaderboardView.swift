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
    var username: String?
    let timestamp: Date
}

struct UserScoreSummary {
    let bestScore: Int?
    let latestScore: Int?
    let gamesPlayed: Int
}

enum LeaderboardPeriod: String, CaseIterable, Identifiable {
    case week
    case month

    var id: Self { self }

    var title: String {
        switch self {
        case .week: return "This Week"
        case .month: return "This Month"
        }
    }

    var emptyMessage: String {
        switch self {
        case .week: return "No community scores logged this week yet."
        case .month: return "No community scores logged this month yet."
        }
    }

    func dateInterval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        switch self {
        case .week:
            let start = QuizScoreLogger.startOfLeaderboardWeek(for: date, calendar: calendar)
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? date
            return DateInterval(start: start, end: end)
        case .month:
            return calendar.dateInterval(of: .month, for: date)
                ?? DateInterval(start: calendar.startOfDay(for: date), duration: 1)
        }
    }
}

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @ObservedObject private var readingProgress = ReadingProgressService.shared
    @State private var selectedPeriod: LeaderboardPeriod = .week
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

                Section {
                    Picker("Leaderboard period", selection: $selectedPeriod) {
                        ForEach(LeaderboardPeriod.allCases) { period in
                            Text(period.title).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    if let errorMessage = viewModel.errorMessage {
                        Text("Couldn't load community scores: \(errorMessage)")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .homeCard()
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else if viewModel.entries.isEmpty {
                        Text(selectedPeriod.emptyMessage)
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
                } header: {
                    Text("Top Scores (\(selectedPeriod.title))")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("Leaderboard")
        .onAppear {
            viewModel.fetchLeaderboard(currentUserID: currentUserID, period: selectedPeriod)
        }
        .onChange(of: selectedPeriod) { _, period in
            viewModel.fetchLeaderboard(currentUserID: currentUserID, period: period)
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
    private var resolvedNames: [String: String] = [:]
    private let quizType = "WhoSaidThat"

    func fetchLeaderboard(
        currentUserID: String?,
        period: LeaderboardPeriod = .week,
        limit: Int = 10,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
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

        let scores = db.collection("quizScores")
        let leaderboardQuery: Query
        switch period {
        case .week:
            let weekKey = QuizScoreLogger.leaderboardWeekKey(for: now, calendar: calendar)
            leaderboardQuery = scores
                .whereField("quizType", isEqualTo: quizType)
                .whereField("leaderboardWeek", isEqualTo: weekKey)
                .order(by: "score", descending: true)
                .order(by: "timestamp", descending: true)
                .limit(to: 200)
        case .month:
            let interval = period.dateInterval(containing: now, calendar: calendar)
            leaderboardQuery = scores
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: interval.start))
                .whereField("timestamp", isLessThan: Timestamp(date: interval.end))
        }

        leaderboardQuery.getDocuments { [weak self] snapshot, error in
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

                let runs = docs.compactMap { doc -> LeaderboardEntry? in
                    let data = doc.data()
                    guard data["quizType"] as? String == self.quizType else { return nil }
                    let userID = data["userID"] as? String ?? "unknown"
                    let score = data["score"] as? Int ?? 0
                    let rawUsername = (data["username"] as? String)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let username: String?
                    if let rawUsername, !QuizScoreLogger.isPlaceholderDisplayName(rawUsername) {
                        username = rawUsername
                    } else {
                        username = nil
                    }
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? .distantPast
                    return LeaderboardEntry(userID: userID, score: score, username: username, timestamp: timestamp)
                }
                let results = Self.bestEntriesPerUser(from: runs, limit: limit)

                DispatchQueue.main.async {
                    self.entries = results
                    self.resolveMissingUsernames()
                    completeOneRequest()
                }
            }

        guard let currentUserID else { return }

        db.collection("quizScores")
            .whereField("userID", isEqualTo: currentUserID)
            .whereField("quizType", isEqualTo: quizType)
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

    nonisolated static func bestEntriesPerUser(from runs: [LeaderboardEntry], limit: Int) -> [LeaderboardEntry] {
        var bestByUser: [String: LeaderboardEntry] = [:]

        for run in runs where run.userID != "unknown" {
            guard let existing = bestByUser[run.userID] else {
                bestByUser[run.userID] = run
                continue
            }

            if run.score > existing.score || (run.score == existing.score && run.timestamp > existing.timestamp) {
                bestByUser[run.userID] = run
                continue
            }

            if (existing.username?.isEmpty ?? true), let username = run.username, !username.isEmpty {
                bestByUser[run.userID] = LeaderboardEntry(
                    userID: existing.userID,
                    score: existing.score,
                    username: username,
                    timestamp: existing.timestamp
                )
            }
        }

        return bestByUser.values
            .sorted {
                if $0.score != $1.score {
                    return $0.score > $1.score
                }
                if $0.timestamp != $1.timestamp {
                    return $0.timestamp > $1.timestamp
                }
                return $0.userID < $1.userID
            }
            .prefix(limit)
            .map { $0 }
    }

    private func resolveMissingUsernames() {
        let unresolvedUserIDs = Set(
            entries
                .filter { ($0.username?.isEmpty ?? true) && $0.userID != "unknown" }
                .map(\.userID)
        )

        for userID in unresolvedUserIDs {
            resolveDisplayName(for: userID) { [weak self] name in
                DispatchQueue.main.async {
                    guard let self else { return }
                    guard let index = self.entries.firstIndex(where: { $0.userID == userID }) else { return }
                    self.entries[index].username = name
                }
            }
        }
    }

    private func resolveDisplayName(for userID: String, completion: @escaping (String) -> Void) {
        if let cached = resolvedNames[userID] {
            completion(cached)
            return
        }

        db.collection("users").document(userID).getDocument { [weak self] snapshot, _ in
            let name = (snapshot?.data()?["displayName"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let resolved: String
            if let name, !name.isEmpty, !QuizScoreLogger.isPlaceholderDisplayName(name) {
                resolved = name
            } else {
                resolved = "User \(userID.prefix(6))"
            }
            DispatchQueue.main.async {
                self?.resolvedNames[userID] = resolved
                completion(resolved)
            }
        }
    }
}
