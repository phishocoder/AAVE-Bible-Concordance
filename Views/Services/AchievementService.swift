import Foundation

@MainActor
final class AchievementService: ObservableObject {
    static let shared = AchievementService()

    @Published private(set) var unlockedIDs: Set<String>
    @Published var lastUnlocked: AchievementUnlock?

    private let defaults = UserDefaults.standard
    private let storageKey = "achievements.unlocked"
    private let dateKeyPrefix = "achievements.unlockedAt."
    private let legacyNotesKey = "verseNotes"

    private init() {
        let stored = defaults.array(forKey: storageKey) as? [String] ?? []
        unlockedIDs = Set(stored)
        runLegacyFirstNoteMigrationIfNeeded()
    }

    func isUnlocked(_ id: AchievementID) -> Bool {
        unlockedIDs.contains(id.rawValue)
    }

    func unlock(_ id: AchievementID) {
        guard !unlockedIDs.contains(id.rawValue) else { return }
        unlockedIDs.insert(id.rawValue)
        defaults.set(Array(unlockedIDs), forKey: storageKey)
        let now = Date()
        defaults.set(now.timeIntervalSince1970, forKey: dateKeyPrefix + id.rawValue)
        lastUnlocked = AchievementUnlock(
            achievement: Achievement(
                id: id,
                title: id.title,
                detail: id.detail,
                icon: id.icon,
                isUnlocked: true,
                unlockedAt: now
            )
        )
    }

    private func unlockSilently(_ id: AchievementID, at date: Date = Date()) {
        guard !unlockedIDs.contains(id.rawValue) else { return }
        unlockedIDs.insert(id.rawValue)
        defaults.set(Array(unlockedIDs), forKey: storageKey)
        defaults.set(date.timeIntervalSince1970, forKey: dateKeyPrefix + id.rawValue)
    }

    private func runLegacyFirstNoteMigrationIfNeeded() {
        guard !isUnlocked(.firstNote) else { return }
        guard let data = defaults.data(forKey: legacyNotesKey),
              let notes = try? JSONDecoder().decode([String: String].self, from: data) else {
            return
        }

        let hasAnyNote = notes.values.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard hasAnyNote else { return }
        unlockSilently(.firstNote)
    }

    func recordHighlight() {
        unlock(.firstHighlight)
    }

    func recordShare() {
        unlock(.firstShare)
    }

    func recordNoteCreated() {
        unlock(.firstNote)
    }

    func handleStreak(_ currentStreak: Int) {
        if currentStreak >= 3 {
            unlock(.streak3)
        }
        if currentStreak >= 7 {
            unlock(.streak7)
        }
    }

    func recordBookFinished() {
        unlock(.finishBook)
    }

    var achievements: [Achievement] {
        AchievementID.allCases.map { id in
            Achievement(
                id: id,
                title: id.title,
                detail: id.detail,
                icon: id.icon,
                isUnlocked: isUnlocked(id),
                unlockedAt: unlockedDate(for: id)
            )
        }
    }

    func unlockedDate(for id: AchievementID) -> Date? {
        let key = dateKeyPrefix + id.rawValue
        let timeInterval = defaults.double(forKey: key)
        return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }

    func recentUnlocked(limit: Int = 3) -> [Achievement] {
        achievements
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedAt ?? .distantPast) > ($1.unlockedAt ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    func clearLastUnlocked() {
        lastUnlocked = nil
    }
}

enum AchievementID: String, CaseIterable {
    case firstHighlight
    case firstShare
    case firstNote
    case streak3
    case streak7
    case finishBook
    case perfectQuizScore

    var title: String {
        switch self {
        case .firstHighlight: return "First Highlight"
        case .firstShare: return "First Share"
        case .firstNote: return "First Note"
        case .streak3: return "3-Day Streak"
        case .streak7: return "7-Day Streak"
        case .finishBook: return "Finish a Book"
        case .perfectQuizScore: return "Perfect Score"
        }
    }

    var detail: String {
        switch self {
        case .firstHighlight: return "Highlight your first verse."
        case .firstShare: return "Share a verse for the first time."
        case .firstNote: return "Create your first verse note."
        case .streak3: return "Read on 3 consecutive days."
        case .streak7: return "Read on 7 consecutive days."
        case .finishBook: return "Read the final verse of any book."
        case .perfectQuizScore: return "Score 10/10 in Who Said That?!"
        }
    }

    var icon: String {
        switch self {
        case .firstHighlight: return "highlighter"
        case .firstShare: return "square.and.arrow.up"
        case .firstNote: return "note.text"
        case .streak3: return "flame"
        case .streak7: return "flame.fill"
        case .finishBook: return "bookmark.fill"
        case .perfectQuizScore: return "crown.fill"
        }
    }
}

struct Achievement: Identifiable {
    let id: AchievementID
    let title: String
    let detail: String
    let icon: String
    let isUnlocked: Bool
    let unlockedAt: Date?
}

struct AchievementUnlock: Identifiable {
    let id = UUID()
    let achievement: Achievement
}
