//
//  CreditsView.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/16/25.
//

import SwiftUI

struct CreditsView: View {
    private let sections: [CreditSection] = [
        CreditSection(title: "Development", rows: [
            CreditRow(label: "Developer", value: "Phil Shobo", tint: .blue)
        ]),
        CreditSection(title: "Content", rows: [
            CreditRow(label: "AAVE Translation", value: "AAVE Bible Project", tint: .purple),
            CreditRow(label: "NET Translation", value: "NET Bible", tint: .teal)
        ]),
        CreditSection(title: "Version", rows: [
            CreditRow(label: "App Version", value: "1.2", tint: .indigo)
        ])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.title3)
                            .fontWeight(.semibold)

                        VStack(spacing: 12) {
                            ForEach(section.rows) { row in
                                CreditsRow(row: row)
                            }
                        }
                    }
                    .glassCard()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .scrollIndicators(.hidden)
        .glassBackground()
        .navigationTitle("Credits")
        .applyGlassToolbar()
    }
}

private struct CreditSection: Identifiable {
    let id = UUID()
    let title: String
    let rows: [CreditRow]
}

private struct CreditRow: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let tint: Color
}

private struct CreditsRow: View {
    let row: CreditRow
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let backgroundFill = colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.65)
        let strokeOpacity = colorScheme == .dark ? 0.08 : 0.25

        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(colors: [row.tint.opacity(0.95), row.tint.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "sparkles")
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(row.label)
                    .fontWeight(.medium)
                Text(row.value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
        )
    }
}
