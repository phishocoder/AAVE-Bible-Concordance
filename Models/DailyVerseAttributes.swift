import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct DailyVerseAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var reference: String
        var excerpt: String
        var verseId: String
        var versionLabel: String
        var isJesusSaid: Bool
    }

    var activityId: String
}
