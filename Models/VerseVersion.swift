import Foundation

enum VerseVersion: String, CaseIterable, Sendable {
    case aave = "AAVE"
    case kjv = "KJV"
    case esv = "ESV"
    case net = "NET"

    var label: String { rawValue }
}
