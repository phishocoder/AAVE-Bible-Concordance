import Foundation

@MainActor
final class ReadingProgressService: ObservableObject {
    static let shared = ReadingProgressService()

    @Published private(set) var lastReadDate: Date?
    @Published private(set) var currentStreak: Int
    @Published private(set) var longestStreak: Int
    @Published private(set) var versesReadToday: Int
    @Published var dailyGoalVerses: Int {
        didSet {
            defaults.set(dailyGoalVerses, forKey: Keys.dailyGoalVerses)
        }
    }

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    private var readVerseIDs: Set<String> = []
    private var lastSignalTimes: [String: Date] = [:]
    private let throttleInterval: TimeInterval = 3

    private enum Keys {
        static let lastReadDate = "reading.lastReadDate"
        static let currentStreak = "reading.currentStreak"
        static let longestStreak = "reading.longestStreak"
        static let versesReadToday = "reading.versesReadToday"
        static let dailyGoalVerses = "reading.dailyGoalVerses"
        static let versesReadDay = "reading.versesReadDay"
    }

    private init() {
        lastReadDate = defaults.object(forKey: Keys.lastReadDate) as? Date
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        versesReadToday = defaults.integer(forKey: Keys.versesReadToday)
        let savedGoal = defaults.integer(forKey: Keys.dailyGoalVerses)
        dailyGoalVerses = savedGoal > 0 ? savedGoal : 10
        syncDayState(for: Date())
    }

    func markVerseRead(_ reference: VerseReference) {
        let now = Date()
        syncDayState(for: now)

        let id = reference.id
        if let lastSignal = lastSignalTimes[id],
           now.timeIntervalSince(lastSignal) < throttleInterval {
            return
        }
        lastSignalTimes[id] = now

        guard !readVerseIDs.contains(id) else { return }
        readVerseIDs.insert(id)
        versesReadToday += 1
        defaults.set(versesReadToday, forKey: Keys.versesReadToday)

        updateStreak(for: now)
        lastReadDate = now
        defaults.set(now, forKey: Keys.lastReadDate)

        checkBookCompletion(reference)
    }

    private func syncDayState(for now: Date) {
        let today = calendar.startOfDay(for: now)
        let storedDay = defaults.object(forKey: Keys.versesReadDay) as? Date
        if storedDay == nil || storedDay != today {
            versesReadToday = 0
            defaults.set(0, forKey: Keys.versesReadToday)
            defaults.set(today, forKey: Keys.versesReadDay)
            readVerseIDs.removeAll()
            lastSignalTimes.removeAll()
        }
    }

    private func updateStreak(for now: Date) {
        let today = calendar.startOfDay(for: now)
        if let lastReadDate {
            let lastDay = calendar.startOfDay(for: lastReadDate)
            if lastDay == today {
                return
            }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        defaults.set(currentStreak, forKey: Keys.currentStreak)
        defaults.set(longestStreak, forKey: Keys.longestStreak)

        AchievementService.shared.handleStreak(currentStreak)
    }

    private func checkBookCompletion(_ reference: VerseReference) {
        guard let chapterMap = chapterVerseCount[reference.book],
              let lastChapter = chapterMap.keys.max(),
              let lastVerse = chapterMap[lastChapter] else {
            return
        }

        if reference.chapter == lastChapter && reference.verse == lastVerse {
            AchievementService.shared.recordBookFinished()
        }
    }
}
