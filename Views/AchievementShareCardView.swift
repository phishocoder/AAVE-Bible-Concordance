import SwiftUI

struct AchievementShareCardView: View {
    let achievement: Achievement
    let unlockedAt: Date?

    var body: some View {
        ZStack {
            // Background
            GlassTheme.backgroundGradient(for: .dark)
                .overlay(Color.black.opacity(0.25))

            // Foreground card
            VStack(spacing: 22) {
                // Top brand mark
                HStack {
                    Text("AAVE")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.red, Color.orange, Color.yellow, Color.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Bible")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                    Spacer()
                }

                Divider()
                    .overlay(Color.white.opacity(0.12))

                // Icon + label
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.16), lineWidth: 1)
                            )

                        Image(systemName: achievement.icon)
                            .font(.system(size: 56, weight: .semibold))
                            .foregroundStyle(Color.orange)
                    }
                    .frame(width: 120, height: 120)

                    Text("Achievement Unlocked")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                }

                // Title + detail
                VStack(spacing: 10) {
                    Text(achievement.title)
                        .font(.system(size: 46, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)

                    Text(achievement.detail)
                        .font(.system(size: 24, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.82))
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                        .lineLimit(4)
                }

                // Unlocked date
                if let unlockedAt {
                    Text("Unlocked \(formattedDate(unlockedAt))")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.top, 4)
                }

                Spacer(minLength: 0)

                // Footer
                HStack {
                    Text("Share your progress")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.70))

                    Spacer()

                    Text("#AAVEBible")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.80))
                }
            }
            .padding(36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 30, x: 0, y: 18)
            )
            .padding(56)
        }
        .frame(width: 1080, height: 1350)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func renderImage(for achievement: Achievement) -> UIImage? {
        let renderer = ImageRenderer(content: AchievementShareCardView(achievement: achievement, unlockedAt: achievement.unlockedAt))
        renderer.proposedSize = ProposedViewSize(width: 1080, height: 1350)
        renderer.scale = 3
        return renderer.uiImage
    }
}
