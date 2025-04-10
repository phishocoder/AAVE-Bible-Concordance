//
//  SettingsViewModel.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/8/25.
//
import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("appearanceMode") var appearanceMode = "system" // "system", "light", or "dark"
    @AppStorage("fontSize") var fontSize: Double = 16
    // Other properties remain unchanged
    @AppStorage("showCommentary") var showCommentary = true
    @AppStorage("preferredTranslation") var preferredTranslation = "AAVE"
    @AppStorage("showAlternateTranslation") var showAlternateTranslation = true
    @AppStorage("verseOfDayTestament") var verseOfDayTestament = "Both" // New property
    @AppStorage("verseOfDayBook") var verseOfDayBook = "Any" // New property
    @AppStorage("verseOfDayTranslation") var verseOfDayTranslation = "AAVE" // New property
    @AppStorage("tagline") var tagline = "God's Word. Our Voice." // New property
    @AppStorage("fontFamily") var fontFamily = "Default" // New property
    
    static let shared = SettingsViewModel()
    
    let availableTaglines = [
        "God's Word. Our Voice.",
        "Scripture, but make it real.",
        "The Bible, the way we talk.",
        "Bridging the Gap Between The Word & The Culture.",
        "From Genesis to Revelation, No Cap."
    ]
    
    let availableFonts = [
        "Default",
        "Serif",
        "Sans-serif",
        "Monospace"
    ]
    
    init() {
        print("DEBUG: Settings initialized")
        print("DEBUG: Show commentary: \(showCommentary)")
    }
}

