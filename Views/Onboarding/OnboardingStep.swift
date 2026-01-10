import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case vibe
    case tone
    case nudge

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .welcome:
            return "Welcome to AAVE Bible"
        case .vibe:
            return "What's your faith vibe right now?"
        case .tone:
            return "How you want it to feel?"
        case .nudge:
            return "Want a little daily nudge?"
        }
    }
}
