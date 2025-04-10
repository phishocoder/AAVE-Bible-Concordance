//
//  PreferenceKeys.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
