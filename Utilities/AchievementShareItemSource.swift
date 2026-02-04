import UIKit
import LinkPresentation

final class AchievementShareItemSource: NSObject, UIActivityItemSource {
    private let image: UIImage
    private let title: String
    private let icon: UIImage?
    private let url: URL?

    init(image: UIImage, title: String, icon: UIImage?, url: URL?) {
        self.image = image
        self.title = title
        self.icon = icon
        self.url = url
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        image
    }

    func activityViewControllerLinkMetadata(
        _ activityViewController: UIActivityViewController
    ) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.imageProvider = NSItemProvider(object: image)
        if let icon {
            metadata.iconProvider = NSItemProvider(object: icon)
        }
        if let url {
            metadata.originalURL = url
        }
        return metadata
    }
}
