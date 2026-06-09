import Foundation

enum IntelligenceAvailability: String, Equatable, Sendable {
    case available
    case deviceNotEligible
    case notEnabled
    case modelNotReady
    case unsupported

    var displayName: String {
        switch self {
        case .available:
            return "Available"
        case .deviceNotEligible:
            return "Device Not Eligible"
        case .notEnabled:
            return "Apple Intelligence Not Enabled"
        case .modelNotReady:
            return "Model Not Ready"
        case .unsupported:
            return "Unsupported"
        }
    }
}
