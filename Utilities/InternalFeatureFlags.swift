import Foundation

enum InternalFeatureFlags {
#if DEBUG
    static let naturalLanguageScriptureSearchEnabled = true
#else
    static let naturalLanguageScriptureSearchEnabled = false
#endif
}
