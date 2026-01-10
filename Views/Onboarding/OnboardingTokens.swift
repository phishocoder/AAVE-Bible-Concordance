import SwiftUI

enum OnboardingTokens {
    static let accent = Color.blue
    static let secondaryText = Color.secondary
    static let border = Color.white.opacity(0.18)

    static func background(for colorScheme: ColorScheme) -> LinearGradient {
        GlassTheme.backgroundGradient(for: colorScheme)
    }
}
