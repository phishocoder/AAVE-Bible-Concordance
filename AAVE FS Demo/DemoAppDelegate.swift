import UIKit
import FullStory
import CryptoKit

final class DemoAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("ℹ️ FullStory will initialize from FullStory.json (CLI flow)")
        if let url = Bundle.main.url(forResource: "FullStory", withExtension: "json") {
            print("✅ Found FullStory.json at \(url.path)")
            logFullStorySHA1(at: url)
        } else {
            print("❌ FullStory.json missing from bundle")
        }
        return true
    }
}

private func logFullStorySHA1(at url: URL) {
    do {
        let data = try Data(contentsOf: url)
        let digest = Insecure.SHA1.hash(data: data)
        let hashString = digest.map { String(format: "%02x", $0) }.joined()
        print("🔐 FullStory.json SHA1: \(hashString)")
    } catch {
        print("⚠️ Unable to read FullStory.json for SHA1: \(error.localizedDescription)")
    }
}
