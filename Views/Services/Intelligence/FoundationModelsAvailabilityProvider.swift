import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum FoundationModelsAvailabilityProvider {
    static var availability: IntelligenceAvailability {
#if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return .available
            case .unavailable(.deviceNotEligible):
                return .deviceNotEligible
            case .unavailable(.appleIntelligenceNotEnabled):
                return .notEnabled
            case .unavailable(.modelNotReady):
                return .modelNotReady
            }
        }
#endif
        return .unsupported
    }
}
