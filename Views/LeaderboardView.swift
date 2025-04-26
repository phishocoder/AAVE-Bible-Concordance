//
//  LeaderboardView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/26/25.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var leaderboardService = LeaderboardService()

    var body: some View {
        VStack {
            Text("Top Scores")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            if leaderboardService.topScores.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "trophy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No scores yet.")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                List {
                    ForEach(Array(leaderboardService.topScores.enumerated()), id: \.offset) { index, score in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    if index == 0 {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                    } else if index == 1 {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.gray)
                                    } else if index == 2 {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.brown)
                                    }

                                    Text("User: \(shortenUserID(score.userID))")
                                        .font(.headline)
                                }

                                Text("Score: \(score.score)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(score.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            leaderboardService.fetchTopScores()
        }
    }

    private func shortenUserID(_ id: String) -> String {
        if id.count <= 8 {
            return id
        }
        let prefix = id.prefix(4)
        let suffix = id.suffix(4)
        return "\(prefix)...\(suffix)"
    }
}
