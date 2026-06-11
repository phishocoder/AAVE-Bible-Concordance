import Foundation

enum InternalFeatureFlags {
#if DEBUG
    private static let isDebugBuild = true
#else
    private static let isDebugBuild = false
#endif

    static var naturalLanguageScriptureSearchEnabled: Bool {
        naturalLanguageScriptureSearchEnabled(isDebugBuild: isDebugBuild)
    }

    static var studyGuideFoundationModelsEnabled: Bool {
        studyGuideFoundationModelsEnabled(isDebugBuild: isDebugBuild)
    }

    static func naturalLanguageScriptureSearchEnabled(isDebugBuild: Bool) -> Bool {
        isDebugBuild
    }

    static func studyGuideFoundationModelsEnabled(isDebugBuild: Bool) -> Bool {
        isDebugBuild
    }
}
