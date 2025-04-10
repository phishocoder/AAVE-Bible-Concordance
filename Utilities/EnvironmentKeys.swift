//
//  EnvironmentKeys.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/13/25.
//

import SwiftUI

private struct NavigationBookKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

private struct NavigationChapterKey: EnvironmentKey {
    static let defaultValue: Int? = nil
}

extension EnvironmentValues {
    var navigationBook: String? {
        get { self[NavigationBookKey.self] }
        set { self[NavigationBookKey.self] = newValue }
    }
    
    var navigationChapter: Int? {
        get { self[NavigationChapterKey.self] }
        set { self[NavigationChapterKey.self] = newValue }
    }
}
