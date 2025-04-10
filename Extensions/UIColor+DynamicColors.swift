//
//  UIColor+DynamicColors.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/18/25.
//

import UIKit

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
