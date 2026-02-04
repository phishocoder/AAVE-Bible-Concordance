import SwiftUI

struct AchievementShareCardView: View {
    let achievementTitle: String
    let achievementSubtitle: String
    let badgeIconName: String
    let dateOrStreakLabel: String?
    let backgroundImage: Image?
    let brandMark: String
    let hashtag: String?
    let callToAction: String?

    private let cardSize = CGSize(width: 1080, height: 1080)
    private let innerCardSize = CGSize(width: 918, height: 918)

    var body: some View {
        ZStack {
            backgroundLayer

            VStack {
                HStack {
                    Text(brandMark)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.horizontal, 24)

                Spacer()

                innerCard

                Spacer()
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
        .shadow(color: .black.opacity(0.24), radius: 22, x: 0, y: 14)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let backgroundImage {
            backgroundImage
                .resizable()
                .scaledToFill()
                .blur(radius: 8)
                .overlay(Color.black.opacity(0.28))
        } else {
            AAVEColors.brandGradient
                .overlay(Color.black.opacity(0.22))
        }
    }

    private var badgeBlock: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.35), lineWidth: 2)
                    )
                    .frame(width: 176, height: 176)

                Image(systemName: badgeIconName)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(AAVEColors.brandGold)
            }

            Text("Achievement Unlocked")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
        }
    }

    private var innerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Spacer()
                badgeBlock
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievementTitle)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(achievementSubtitle)
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)

                if let dateOrStreakLabel {
                    Text(dateOrStreakLabel)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }

                if let callToAction {
                    Text(callToAction)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.top, 1)
                }
            }

            HStack {
                Spacer()
                if let hashtag {
                    Text(hashtag)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .padding(24)
        .frame(width: innerCardSize.width, height: innerCardSize.height, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.black.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.22), radius: 16, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .blur(radius: 1)
        )
    }
}
