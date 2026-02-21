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
            if !userDataManager.history.isEmpty {
                ForEach(Array(userDataManager.history.enumerated()), id: \.element.id) { _, reference in
                    NavigationLink {
                        VerseDetailView(reference: reference)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(reference.displayString)
                            Text(reference.timestamp.formatted())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .homeCard()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .glassBackground()
        .applyGlassToolbar()
        .navigationTitle("History")
        .overlay {
            if userDataManager.history.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your reading history will appear here")
                )
            }
        }
    }
}
