//
//  UIColor+DynamicColors.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/18/25.
//

import UIKit
import SwiftUI

extension UIColor {
    static var dynamicBackground: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }
    
    static var dynamicBlack: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    static var dynamicOutline: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }
    
    static var aaveLogoSecondA: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0, green: 0, blue: 0, alpha: 1.0) : // Black in dark mode
                UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)   // Black in light mode
        }
    }
    
    static var aaveLogoSecondAOutline: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 1, green: 1, blue: 1, alpha: 1.0) : // White outline in dark mode
                UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)   // No outline in light mode
        }
    }
}

enum AAVEColors {
    private static func color(hex: UInt, alpha: Double = 1.0) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    // Brand palette (from app icon)
    static let brandRed = color(hex: 0xD03110)
    static let brandGold = color(hex: 0xF2AA19)
    static let brandOrange = color(hex: 0xE95D19)
    static let brandGreen = color(hex: 0x1D772C)
    static let brandOlive = color(hex: 0x9EA823)
    static let brandBrown = color(hex: 0x4B2410)
    static let paper = color(hex: 0xFDFBF8)

    // Common usage
    static let accent = brandGold
    static let textPrimary = Color("TextColor")
    static let textOnBrand = brandBrown
    static let surface = Color("PrimaryBackground")
    static let surfaceSecondary = Color("SecondaryBackground")

    static let brandGradient = LinearGradient(
        colors: [brandRed, brandGold, brandGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AAVETypography {
    // Launch screen / branding
    static let logo = Font.system(size: 72, weight: .bold, design: .rounded)
    static let launchSubtitle = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let tagline = Font.system(.title3, design: .rounded).weight(.semibold)

    // General UI
    static let sectionTitle = Font.system(.headline, design: .rounded).weight(.semibold)
    static let button = Font.system(.headline, design: .rounded).weight(.medium)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)

    // Component-specific
    static let toolIcon = Font.system(size: 22, weight: .semibold)
    static let toolbarIcon = Font.system(size: 19, weight: .semibold)
    static let chapterNumber = Font.system(.headline)
}
