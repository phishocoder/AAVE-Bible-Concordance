//
//  LeaderboardView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var leaderboardService = LeaderboardService.shared
    
    var body: some View {
        NavigationView {
            List(leaderboardService.topScores) { entry in
                VStack(alignment: .leading) {
                    Text("User: \(entry.userID.prefix(6))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Score: \(entry.score)")
                        .font(.headline)
                    Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Top Scores")
            .onAppear {
                leaderboardService.fetchTopScores()
            }
        }
    }
}
