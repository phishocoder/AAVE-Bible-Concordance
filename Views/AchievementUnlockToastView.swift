import SwiftUI

struct AchievementUnlockToastView: View {
    let unlock: AchievementUnlock
    let onShare: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievement Unlocked 🎉")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: unlock.achievement.icon)
                    .font(.title3)
                    .foregroundStyle(Color.orange)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(unlock.achievement.title)
                        .font(.headline)
                    Text(unlock.achievement.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Nice")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)

                Button(action: onShare) {
                    Text("Share")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.blue.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .homeCard()
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
