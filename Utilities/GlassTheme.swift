import SwiftUI

/// Centralizes the updated "Liquid Glass" inspired theming used across the app.
enum GlassTheme {
    static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(hex: 0x0F172A).opacity(0.95),
                         Color(hex: 0x111827).opacity(0.9),
                         Color(hex: 0x312E81).opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: 0xF8FAFC),
                         Color(hex: 0xE2E8F0),
                         Color(hex: 0xE0EAFF)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    struct CardStyle: ViewModifier {
        @Environment(\.colorScheme) private var colorScheme

        func body(content: Content) -> some View {
            let strokeOpacity = colorScheme == .dark ? 0.35 : 0.2
            let shadowColor = colorScheme == .dark ? Color.black.opacity(0.28) : Color.black.opacity(0.08)
            let material: Material = colorScheme == .dark ? .ultraThinMaterial : .thinMaterial

            return content
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(material)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(strokeOpacity), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: shadowColor, radius: 18, x: 0, y: 18)
                )
        }
    }

    struct HomeCardStyle: ViewModifier {
        @Environment(\.colorScheme) private var colorScheme

        func body(content: Content) -> some View {
            let strokeOpacity = colorScheme == .dark ? 0.3 : 0.2
            let shadowColor = colorScheme == .dark ? Color.black.opacity(0.25) : Color.black.opacity(0.08)
            let material: Material = colorScheme == .dark ? .ultraThinMaterial : .thinMaterial

            return content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(material)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(strokeOpacity), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: shadowColor, radius: 14, x: 0, y: 14)
                )
        }
    }

    /// Applies a blurred glass surface to toolbars & tab bars.
    struct ToolbarAppearance: ViewModifier {
        @Environment(\.colorScheme) private var colorScheme

        func body(content: Content) -> some View {
            content
                .toolbarBackground(colorScheme == .dark ? .ultraThinMaterial : .thinMaterial, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
        }
    }

    struct BackgroundModifier: ViewModifier {
        @Environment(\.colorScheme) private var colorScheme

        func body(content: Content) -> some View {
            content
                .background(
                    GlassTheme.backgroundGradient(for: colorScheme)
                        .ignoresSafeArea()
                )
        }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassTheme.CardStyle())
    }

    func homeCard() -> some View {
        modifier(GlassTheme.HomeCardStyle())
    }

    func applyGlassToolbar() -> some View {
        modifier(GlassTheme.ToolbarAppearance())
    }

    func glassBackground() -> some View {
        modifier(GlassTheme.BackgroundModifier())
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
