import SwiftUI
import UIKit

struct AchievementsView: View {
    @ObservedObject private var achievementService = AchievementService.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPreparingShare = false
    @State private var shareErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(achievementService.achievements) { achievement in
                    AchievementRow(achievement: achievement) {
                        guard achievement.isUnlocked else { return }
                        Task { @MainActor in
                            print("[Share] User initiated share for \(achievement.title)")
                            isPreparingShare = true
                            guard let items = AchievementShareRenderer.shareItems(for: achievement) else {
                                shareErrorMessage = "Unable to generate share image. Please try again."
                                isPreparingShare = false
                                return
                            }
                            AchievementSharePresenter.present(items: items)
                            isPreparingShare = false
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .scrollIndicators(.hidden)
        .glassBackground()
        .navigationTitle("Achievements")
        .applyGlassToolbar()
        .overlay {
            if isPreparingShare {
                ProgressView("Preparing share…")
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .alert("Share Failed", isPresented: Binding(
            get: { shareErrorMessage != nil },
            set: { if !$0 { shareErrorMessage = nil } }
        )) {
            Button("OK") { shareErrorMessage = nil }
        } message: {
            Text(shareErrorMessage ?? "")
        }
    }
}

private struct AchievementRow: View {
    let achievement: Achievement
    let onShare: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? Color.orange : Color.secondary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(achievement.isUnlocked ? Color.orange.opacity(0.15) : Color.gray.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if achievement.isUnlocked {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.blue)
                        .font(.subheadline)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.blue.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
            } else {
                Text("Locked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.2), lineWidth: 1)
                )
        )
    }
}
