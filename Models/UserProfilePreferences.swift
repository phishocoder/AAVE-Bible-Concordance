import Foundation
import SwiftUI

@MainActor
final class UserProfilePreferences: ObservableObject {
    static let shared = UserProfilePreferences()

    @AppStorage("didCompleteOnboarding") var didCompleteOnboarding = false
    @AppStorage("displayName") var displayName = ""
    @AppStorage("faithVibe") private var faithVibeRaw = FaithVibe.stillFiguringItOut.rawValue
    @AppStorage("tonePreference") private var tonePreferenceRaw = TonePreference.mix.rawValue
    @AppStorage("wantsDailyNudge") var wantsDailyNudge = false

    var faithVibe: FaithVibe {
        get { FaithVibe(rawValue: faithVibeRaw) ?? .stillFiguringItOut }
        set { faithVibeRaw = newValue.rawValue }
    }

    var tonePreference: TonePreference {
        get { TonePreference(rawValue: tonePreferenceRaw) ?? .mix }
        set { tonePreferenceRaw = newValue.rawValue }
    }

    func resetOnboarding() {
        didCompleteOnboarding = false
    }

    func resetForAccountDeletion() {
        didCompleteOnboarding = false
        displayName = ""
        faithVibeRaw = FaithVibe.stillFiguringItOut.rawValue
        tonePreferenceRaw = TonePreference.mix.rawValue
        wantsDailyNudge = false
    }
}

enum FaithVibe: String, CaseIterable, Identifiable {
    case exChurchKid = "Ex-Church Kid"
    case sundayRegular = "Sunday Regular"
    case stillFiguringItOut = "Still Figuring It Out"
    case newToBible = "New to the Bible"
    case spiritualNotReligious = "Spiritual, not religious"

    var id: String { rawValue }

    var welcomeCopy: String {
        switch self {
        case .exChurchKid:
            return "We get it. You have seen the mess. Take your time here."
        case .sundayRegular:
            return "You already know the vibe. This just makes it feel closer."
        case .stillFiguringItOut:
            return "Questions welcome. We are not doing fake perfect over here."
        case .newToBible:
            return "No pressure. We will walk it with you, verse by verse."
        case .spiritualNotReligious:
            return "No church jargon. No pressure. Just Scripture that speaks human."
        }
    }

    var shortLine: String {
        switch self {
        case .exChurchKid:
            return "No pressure here."
        case .sundayRegular:
            return "You already know the rhythm."
        case .stillFiguringItOut:
            return "Questions welcome."
        case .newToBible:
            return "We will walk it with you."
        case .spiritualNotReligious:
            return "No jargon, just Scripture."
        }
    }
}

enum TonePreference: String, CaseIterable, Identifiable {
    case chill = "Keep it chill"
    case deep = "Keep it deep"
    case mix = "Mix both"

    var id: String { rawValue }

    var homeLine: String {
        switch self {
        case .chill:
            return "You good today? Let us get in the Word."
        case .deep:
            return "Let us lock in. One verse at a time."
        case .mix:
            return "Real talk and real depth. Let us read."
        }
    }
}
