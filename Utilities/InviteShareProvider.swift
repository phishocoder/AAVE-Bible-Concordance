import UIKit

enum InviteShareProvider {
    static let imageName = "beta_invite_share_card"
    static let betaLink = "https://officialaavebible.com"

    static func shareItems() -> [Any]? {
        guard let image = UIImage(named: imageName) else {
            print("[InviteShare] ERROR: Missing asset \(imageName)")
            return nil
        }

        let caption = "Scripture. In our voice. Join the AAVE Bible beta: \(betaLink)"
        print("[InviteShare] Share items ready: \([type(of: image), type(of: caption)])")
        return [image, caption]
    }
}
