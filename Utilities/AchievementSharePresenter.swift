import UIKit

enum AchievementSharePresenter {
    private static func debugLog(_ message: @autoclosure () -> String) {
#if DEBUG
        print(message())
#endif
    }

    static func present(items: [Any]) {
        DispatchQueue.main.async {
            debugLog("[Share] Presenting activity controller with items: \(items.map { String(describing: type(of: $0)) })")
            let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
            controller.popoverPresentationController?.sourceView = topViewController()?.view
            controller.popoverPresentationController?.sourceRect = topViewController()?.view.bounds ?? .zero

            guard let presenter = topViewController() else {
                debugLog("[Share] ERROR: No active view controller to present share sheet.")
                return
            }

            presenter.present(controller, animated: true)
        }
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? activeRootViewController()
        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }

    private static func activeRootViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        for scene in scenes {
            if let window = scene.windows.first(where: { $0.isKeyWindow }) {
                return window.rootViewController
            }
        }

        return nil
    }
}
