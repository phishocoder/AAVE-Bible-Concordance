import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var stepIndex = 0
    @Published var selectedVibe: FaithVibe?
    @Published var selectedTone: TonePreference?
    @Published var wantsNudge = false

    let steps = OnboardingStep.allCases

    private let preferences = UserProfilePreferences.shared
    private let notificationManager = NotificationManager.shared

    var currentStep: OnboardingStep {
        steps[stepIndex]
    }

    var canContinue: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .vibe:
            return selectedVibe != nil
        case .tone:
            return selectedTone != nil
        case .nudge:
            return true
        }
    }

    func goBack() {
        stepIndex = max(0, stepIndex - 1)
    }

    func goNext() {
        if stepIndex < steps.count - 1 {
            stepIndex += 1
        }
    }

    func applySelections() {
        if let selectedVibe {
            preferences.faithVibe = selectedVibe
        }
        if let selectedTone {
            preferences.tonePreference = selectedTone
        }
        preferences.wantsDailyNudge = wantsNudge
        if wantsNudge {
            notificationManager.dailyVerseNotificationEnabled = true
            notificationManager.requestAuthorization()
        }
    }

    func completeOnboarding() {
        applySelections()
        preferences.didCompleteOnboarding = true
    }
}
