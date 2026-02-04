import SwiftUI
import UIKit

enum AchievementShareRenderer {
    static let defaultSize = CGSize(width: 1080, height: 1080)

    @MainActor
    static func renderImage(
        achievement: Achievement,
        size: CGSize = defaultSize,
        scale: CGFloat = 3
    ) -> UIImage? {
        guard #available(iOS 16.0, *) else { return nil }

        print("[Share] Rendering share image at size \(Int(size.width))x\(Int(size.height)) scale \(scale)")
        let view = AchievementShareCardView(
            achievementTitle: achievement.title,
            achievementSubtitle: achievement.detail,
            badgeIconName: achievement.icon,
            dateOrStreakLabel: formattedUnlockedLabel(achievement.unlockedAt),
            backgroundImage: nil,
            brandMark: "AAVE Bible",
            hashtag: "#aavebible",
            callToAction: "Join me and get yours."
        )

        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(width: size.width, height: size.height)
        renderer.scale = scale
        let image = renderer.uiImage
        print("[Share] Render complete: \(image == nil ? "nil" : "success")")
        return image
    }

    @MainActor
    static func shareItems(
        for achievement: Achievement,
        deepLink: URL? = URL(string: "https://officialaavebible.com")
    ) -> [Any]? {
        print("[Share] Starting share item build for achievement: \(achievement.title)")
        guard let image = renderImage(achievement: achievement) else { return nil }

        let caption = defaultCaption(for: achievement)
        let captionWithLink = deepLink.map { "\(caption) Join me: \($0.absoluteString)" } ?? caption
        let items: [Any] = [image, captionWithLink]
        print("[Share] Share items ready: \(items.map { String(describing: type(of: $0)) })")
        return items
    }

    static func defaultCaption(for achievement: Achievement) -> String {
        let options = [
            "\(achievement.title) unlocked.",
            "Streak up. \(achievement.title) unlocked.",
            "God kept me consistent. \(achievement.title) unlocked."
        ]
        return options.randomElement() ?? options[0]
    }

    private static func formattedUnlockedLabel(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Unlocked \(formatter.string(from: date))"
    }
}
