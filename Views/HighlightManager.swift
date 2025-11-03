//
//  HighlightManager.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 7/2/25.
//

import Foundation
import SwiftUI

struct HighlightItem: Identifiable, Codable {
    let id: UUID
    let book: String
    let chapter: Int
    let verse: Int
    let dateAdded: Date
    var text: String
    
    // Color components for encoding/decoding
    var colorComponents: [CGFloat]
    
    var color: Color {
        if colorComponents.count >= 3 {
            return Color(
                red: colorComponents[0],
                green: colorComponents[1],
                blue: colorComponents[2],
                opacity: colorComponents.count > 3 ? colorComponents[3] : 1.0
            )
        }
        return .yellow
    }
    
    var reference: VerseReference {
        VerseReference(book: book, chapter: chapter, verse: verse)
    }
    
    init(id: UUID = UUID(), book: String, chapter: Int, verse: Int, text: String, color: Color, dateAdded: Date = Date()) {
        self.id = id
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.dateAdded = dateAdded
        
        // Convert Color to components
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.colorComponents = [red, green, blue, alpha]
    }
}

@MainActor
class HighlightManager: ObservableObject {
    static let shared = HighlightManager()
    
    @Published private(set) var highlights: [HighlightItem] = []
    @Published var highlightUpdateID = UUID()
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "highlightedVerses"
    private let colorsKey = "highlightColors"
    private var refreshTimer: Timer?
    
    private let verseManager = VerseManager.shared
    
    init() {
        loadHighlights()
    }
    
    private func loadHighlights() {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([HighlightItem].self, from: data) {
            highlights = decoded
        }
    }
    
    func isHighlighted(_ reference: VerseReference) -> Bool {
        highlights.contains { $0.reference.key == reference.key }
    }
    
    func getHighlightColor(for reference: VerseReference) -> Color? {
        if let highlight = highlights.first(where: { $0.reference.key == reference.key }) {
            return highlight.color
        }
        return nil
    }
    
    func toggleHighlight(_ reference: VerseReference, text: String = "") {
        if isHighlighted(reference) {
            removeHighlight(reference)
        } else {
            addHighlight(reference, color: .yellow, text: text)
        }
    }
    
    func addHighlight(_ reference: VerseReference, color: Color = .yellow, text: String = "") {
        // If already highlighted, update the color
        if let index = highlights.firstIndex(where: { $0.reference.key == reference.key }) {
            highlights.remove(at: index)
        }
        
        // Create new highlight item
        let highlight = HighlightItem(
            book: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            text: text,
            color: color
        )
        
        highlights.append(highlight)
        saveHighlights()
        scheduleRefresh()
        
        // If text is empty, try to fetch it asynchronously
        if text.isEmpty {
            Task {
                do {
                    let verseText = try await verseManager.getVerse(
                        book: reference.book,
                        chapter: reference.chapter,
                        verse: reference.verse,
                        translation: "AAVE"
                    )
                    
                    await MainActor.run {
                        if let index = self.highlights.firstIndex(where: { $0.reference.key == reference.key }) {
                            var updatedHighlight = self.highlights[index]
                            updatedHighlight.text = verseText
                            self.highlights[index] = updatedHighlight
                            self.saveHighlights()
                        }
                    }
                } catch {
                    print("Failed to fetch verse text for highlight: \(error)")
                }
            }
        }
    }
    
    // Add a non-refreshing version for batch operations
    func addHighlightWithoutRefresh(_ reference: VerseReference, color: Color = .yellow, text: String = "") {
        if let index = highlights.firstIndex(where: { $0.reference.key == reference.key }) {
            highlights.remove(at: index)
        }
        
        let highlight = HighlightItem(
            book: reference.book,
            chapter: reference.chapter,
            verse: reference.verse,
            text: text,
            color: color
        )
        
        highlights.append(highlight)
        saveHighlights()
        // No refresh scheduled
    }
    
    func removeHighlight(_ reference: VerseReference) {
        highlights.removeAll { $0.reference.key == reference.key }
        saveHighlights()
        scheduleRefresh()
    }
    
    // Add a non-refreshing version for batch operations
    func removeHighlightWithoutRefresh(_ reference: VerseReference) {
        highlights.removeAll { $0.reference.key == reference.key }
        saveHighlights()
        // No refresh scheduled
    }
    
    func clearHighlights() {
        highlights.removeAll()
        saveHighlights()
        scheduleRefresh()
    }
    
    func getHighlightedVerses() -> [HighlightItem] {
        return highlights
    }
    
    // Use this for batch operations, then call refreshHighlights() once at the end
    func refreshHighlights() {
        scheduleRefresh()
    }
    
    private func saveHighlights() {
        if let encoded = try? JSONEncoder().encode(highlights) {
            userDefaults.set(encoded, forKey: storageKey)
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
    
    // Update highlight color
    func updateHighlightColor(_ reference: VerseReference, color: Color) {
        if let index = highlights.firstIndex(where: { $0.reference.key == reference.key }) {
            let text = highlights[index].text
            highlights.remove(at: index)
            
            let highlight = HighlightItem(
                book: reference.book,
                chapter: reference.chapter,
                verse: reference.verse,
                text: text,
                color: color
            )
            
            highlights.append(highlight)
            saveHighlights()
            scheduleRefresh()
        }
    }
    
    // Get highlights for a specific book and chapter
    func getHighlights(for book: String, chapter: Int) -> [HighlightItem] {
        return highlights.filter { $0.book == book && $0.chapter == chapter }
    }
    
    // Sort highlights by various criteria
    func getSortedHighlights(by sortOrder: HighlightSortOrder) -> [HighlightItem] {
        switch sortOrder {
        case .dateAdded:
            return highlights.sorted { $0.dateAdded > $1.dateAdded }
        case .book:
            return highlights.sorted { $0.book < $1.book || ($0.book == $1.book && $0.chapter < $1.chapter) ||
                ($0.book == $1.book && $0.chapter == $1.chapter && $0.verse < $1.verse) }
        case .color:
            return highlights.sorted {
                let c1 = $0.colorComponents
                let c2 = $1.colorComponents
                // Simple hue-based sorting
                return c1[0] + c1[1] * 2 + c1[2] * 3 < c2[0] + c2[1] * 2 + c2[2] * 3
            }
        }
    }
}

// Sort order for highlights
enum HighlightSortOrder {
    case dateAdded
    case book
    case color
}

extension VerseReference {
    var key: String {
        "\(book)_\(chapter)_\(verse)"
    }
}
