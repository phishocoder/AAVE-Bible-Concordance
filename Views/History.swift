//
//  History.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//
import SwiftUI

struct HistoryView: View {
    @StateObject private var userDataManager = UserDataManager.shared
    
    var body: some View {
        List {
            if userDataManager.history.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your reading history will appear here")
                )
            } else {
                ForEach(Array(userDataManager.history.enumerated()), id: \.element.id) { _, reference in
                    NavigationLink {
                        VerseDetailView(reference: reference)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(reference.displayString)
                            Text(reference.timestamp.formatted())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}
