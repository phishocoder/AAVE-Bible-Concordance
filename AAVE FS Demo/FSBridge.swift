import Foundation
import FullStory

enum FSBridge {
    static func identify(userId: String,
                         accountTier: String,
                         region: String,
                         lastLogin: Date = Date()) {
        let iso = ISO8601DateFormatter().string(from: lastLogin)
        FS.identify(userId, userVars: [
            "accountTier": accountTier,
            "region": region,
            "lastLogin": iso
        ])
        print("🔎 FS.identify(\(userId)) sent")
    }

    static func page(_ name: String, props: [String: Any] = [:]) {
        let properties = props.isEmpty ? nil : props
        let page = FS.page(withName: name, properties: properties)
        page.start()
        print("📄 FS.page(\(name)) \(props)")
    }

    static func event(_ name: String, props: [String: Any] = [:]) {
        FS.event(name, properties: props)
        print("🎯 FS.event(\(name)) \(props)")
    }
}
