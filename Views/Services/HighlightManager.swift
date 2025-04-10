//
//  HighlightManager.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/12/25.
//

import Foundation
import SwiftUI

class HighlightManager: ObservableObject {
    static let shared = HighlightManager()
    
    @Published private(set) var highlightedVerses: Set<String> = []
    @Published private(set) var highlightColors: [String: Color] = [:]
    @Published var highlightUpdateID = UUID()
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "highlightedVerses"
    private let colorsKey = "highlightColors"
    private var refreshTimer: Timer?
    
    init() {
        loadHighlights()
    }
    
    private func loadHighlights() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            highlightedVerses = decoded
        }
        
        // Load color data as a dictionary of color components
        if let data = userDefaults.data(forKey: colorsKey),
           let colorData = try? JSONDecoder().decode([String: [CGFloat]].self, from: data) {
            for (key, components) in colorData {
                if components.count >= 3 {
                    highlightColors[key] = Color(
                        red: components[0],
                        green: components[1],
                        blue: components[2],
                        opacity: components.count > 3 ? components[3] : 1.0
                    )
                }
            }
        }
    }
    
    func isHighlighted(_ reference: VerseReference) -> Bool {
        highlightedVerses.contains(reference.key)
    }
    
    func getHighlightColor(for reference: VerseReference) -> Color? {
        let key = reference.key
        return highlightColors[key]
    }
    
    func toggleHighlight(_ reference: VerseReference) {
        let key = reference.key
        if highlightedVerses.contains(key) {
            highlightedVerses.remove(key)
            highlightColors.removeValue(forKey: key)
        } else {
            highlightedVerses.insert(key)
            highlightColors[key] = .yellow // Default color
        }
        saveHighlights()
        scheduleRefresh()
    }
    
    func addHighlight(_ reference: VerseReference, color: Color = .yellow) {
        let key = reference.key
        highlightedVerses.insert(key)
        highlightColors[key] = color
        saveHighlights()
        scheduleRefresh()
    }
    
    // Add a non-refreshing version for batch operations
    func addHighlightWithoutRefresh(_ reference: VerseReference, color: Color = .yellow) {
        let key = reference.key
        highlightedVerses.insert(key)
        highlightColors[key] = color
        saveHighlights()
        // No refresh scheduled
    }
    
    func removeHighlight(_ reference: VerseReference) {
        let key = reference.key
        highlightedVerses.remove(key)
        highlightColors.removeValue(forKey: key)
        saveHighlights()
        scheduleRefresh()
    }
    
    // Add a non-refreshing version for batch operations
    func removeHighlightWithoutRefresh(_ reference: VerseReference) {
        let key = reference.key
        highlightedVerses.remove(key)
        highlightColors.removeValue(forKey: key)
        saveHighlights()
        // No refresh scheduled
    }
    
    func clearHighlights() {
        highlightedVerses.removeAll()
        highlightColors.removeAll()
        saveHighlights()
        scheduleRefresh()
    }
    
    func getHighlightedVerses() -> [String] {
        Array(highlightedVerses)
    }
    
    // Use this for batch operations, then call refreshHighlights() once at the end
    func refreshHighlights() {
        scheduleRefresh()
    }
    
    private func saveHighlights() {
        // Save highlights
        if let encoded = try? JSONEncoder().encode(highlightedVerses) {
            userDefaults.set(encoded, forKey: storageKey)
        }
        
        // Save colors as components
        var colorData: [String: [CGFloat]] = [:]
        for (key, color) in highlightColors {
            // Extract color components using UIColor
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            colorData[key] = [red, green, blue, alpha]
        }
        
        if let encoded = try? JSONEncoder().encode(colorData) {
            userDefaults.set(encoded, forKey: colorsKey)
        }
    }
    
    func forceSave() {
        saveHighlights()
    }
    
    private func scheduleRefresh() {
        // Cancel any existing timer
        refreshTimer?.invalidate()
        
        // Schedule a new refresh after a short delay
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.highlightUpdateID = UUID()
                // Post notification but don't trigger another refresh cycle
                NotificationCenter.default.post(name: NSNotification.Name("RefreshVerseHighlights"), object: nil)
            }
        }
    }
}

extension VerseReference {
    var key: String {
        "\(book)_\(chapter)_\(verse)"
    }
}
