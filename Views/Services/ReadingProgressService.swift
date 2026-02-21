import Foundation

@MainActor
final class ReadingProgressService: ObservableObject {
    static let shared = ReadingProgressService()

    @Published private(set) var lastReadDate: Date?
    @Published private(set) var currentStreak: Int
    @Published private(set) var longestStreak: Int
    @Published private(set) var versesReadToday: Int
    @Published private(set) var gracePassMonth: String
    @Published private(set) var gracePassUsedCount: Int
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
        static let gracePassMonth = "reading.gracePassMonth"
        static let gracePassUsedCount = "reading.gracePassUsedCount"
    }

    private init() {
        lastReadDate = defaults.object(forKey: Keys.lastReadDate) as? Date
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        versesReadToday = defaults.integer(forKey: Keys.versesReadToday)
        let savedGoal = defaults.integer(forKey: Keys.dailyGoalVerses)
        dailyGoalVerses = savedGoal > 0 ? savedGoal : 10
        gracePassMonth = defaults.string(forKey: Keys.gracePassMonth) ?? ""
        gracePassUsedCount = defaults.integer(forKey: Keys.gracePassUsedCount)
        resetGracePassIfNewMonth(for: Date())
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
        PersonalizationService.shared.recordReading(reference, at: now)
    }

    private func syncDayState(for now: Date) {
        resetGracePassIfNewMonth(for: now)
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
        resetGracePassIfNewMonth(for: now)
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
                let usedGracePass = applyGracePassIfEligible(today: today)
                currentStreak = usedGracePass ? (currentStreak + 1) : 1
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
        if currentStreak == 7 {
            NotificationManager.shared.scheduleMilestoneCelebration(.streak7)
        }
    }

    var gracePassesRemaining: Int {
        max(0, 1 - gracePassUsedCount)
    }

    private func currentMonthKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        return String(format: "%04d-%02d", year, month)
    }

    private func resetGracePassIfNewMonth(for date: Date) {
        let monthKey = currentMonthKey(for: date)
        guard gracePassMonth != monthKey else { return }
        gracePassMonth = monthKey
        gracePassUsedCount = 0
        defaults.set(gracePassMonth, forKey: Keys.gracePassMonth)
        defaults.set(gracePassUsedCount, forKey: Keys.gracePassUsedCount)
    }

    private func applyGracePassIfEligible(today: Date) -> Bool {
        guard currentStreak > 0,
              gracePassUsedCount < 1,
              let lastReadDate else {
            return false
        }

        let lastDay = calendar.startOfDay(for: lastReadDate)
        let todayDay = calendar.startOfDay(for: today)

        guard lastDay != todayDay,
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: todayDay),
              calendar.isDate(lastDay, inSameDayAs: twoDaysAgo) else {
            return false
        }

        gracePassUsedCount += 1
        defaults.set(gracePassUsedCount, forKey: Keys.gracePassUsedCount)
        return true
    }

    private func checkBookCompletion(_ reference: VerseReference) {
        guard let chapterMap = chapterVerseCount[reference.book],
              let lastChapter = chapterMap.keys.max(),
              let lastVerse = chapterMap[lastChapter] else {
            return
        }

        if reference.chapter == lastChapter && reference.verse == lastVerse {
            AchievementService.shared.recordBookFinished()
            NotificationManager.shared.scheduleMilestoneCelebration(.finishedBook(book: reference.book))
        }
    }
}

@MainActor
final class PersonalizationService: ObservableObject {
    static let shared = PersonalizationService()

    @Published private(set) var state = PersonalizationState.empty

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let bookFrequency = "personalization.bookFrequency"
        static let usageBuckets = "personalization.usageBuckets"
        static let lastReadAt = "personalization.lastReadAt"
        static let lastReadReference = "personalization.lastReadReference"
    }

    private enum UsageBucket: String, CaseIterable {
        case morning
        case midday
        case evening
    }

    private init() {
        refresh(using: UserDataManager.shared.history)
    }

    func recordAppOpen(at date: Date = Date()) {
        incrementUsageBucket(for: date)
        refresh(using: UserDataManager.shared.history)
    }

    func recordReading(_ reference: VerseReference, at date: Date = Date()) {
        var frequencies = loadBookFrequency()
        frequencies[reference.book, default: 0] += 1
        saveBookFrequency(frequencies)

        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastReadAt)
        if let encoded = try? JSONEncoder().encode(reference) {
            defaults.set(encoded, forKey: Keys.lastReadReference)
        }

        incrementUsageBucket(for: date)
        refresh(using: UserDataManager.shared.history)
    }

    func refresh(using history: [VerseReference]) {
        let topBook = mostFrequentBook(from: history)
        let resumeRef = latestReference(from: history)
        let lastReadAt = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastReadAt))
        let hasRecentReading = defaults.double(forKey: Keys.lastReadAt) > 0 &&
            Date().timeIntervalSince(lastReadAt) <= 72 * 60 * 60

        let primary = buildPrimaryRule(
            resumeReference: resumeRef,
            hasRecentReading: hasRecentReading,
            fallbackBook: topBook ?? "Genesis"
        )
        let timeRule = buildTimeRule()
        let exploration = buildExplorationRule(from: topBook)

        state = PersonalizationState(
            primaryTitle: primary.title,
            primaryBody: primary.body,
            primaryActionTitle: primary.actionTitle,
            primaryAction: primary.action,
            timeOfDayCopy: timeRule,
            explorationCopy: exploration.copy,
            explorationBook: exploration.book
        )
    }

    private func buildPrimaryRule(
        resumeReference: VerseReference?,
        hasRecentReading: Bool,
        fallbackBook: String
    ) -> (title: String, body: String, actionTitle: String, action: PersonalizationAction) {
        if hasRecentReading, let resumeReference {
            return (
                title: "Continue where you left off",
                body: "Pick up where you paused: \(resumeReference.book) \(resumeReference.chapter)",
                actionTitle: "Resume",
                action: .resumeVerse(resumeReference)
            )
        }

        return (
            title: "Start fresh",
            body: "You’ve been steady in \(fallbackBook). Want to start there today?",
            actionTitle: "Open \(fallbackBook)",
            action: .openBook(fallbackBook)
        )
    }

    private func buildTimeRule() -> String {
        switch dominantUsageBucket() {
        case .morning:
            return "Morning rhythm: start with one chapter to set your day."
        case .midday:
            return "Midday reset: one verse, one breath, keep moving."
        case .evening:
            return "Evening wind-down: sit with a reflective passage tonight."
        }
    }

    private func buildExplorationRule(from topBook: String?) -> (copy: String, book: String?) {
        guard let topBook else {
            return ("Explore a new book today and build your pattern.", "Genesis")
        }

        let suggested = adjacentBook(inSameTestamentAs: topBook) ?? topBook
        return (
            "You read \(topBook) often. Try \(suggested) next for a connected thread.",
            suggested
        )
    }

    private func latestReference(from history: [VerseReference]) -> VerseReference? {
        if let first = history.first {
            return first
        }
        guard let data = defaults.data(forKey: Keys.lastReadReference),
              let decoded = try? JSONDecoder().decode(VerseReference.self, from: data) else {
            return nil
        }
        return decoded
    }

    private func mostFrequentBook(from history: [VerseReference]) -> String? {
        let frequencies = loadBookFrequency()
        if let top = frequencies.max(by: { $0.value < $1.value })?.key {
            return top
        }
        return history.first?.book
    }

    private func adjacentBook(inSameTestamentAs book: String) -> String? {
        guard let current = bibleBooks.first(where: { $0.name == book }) else {
            return nil
        }

        let sameTestament = bibleBooks.filter { $0.testament == current.testament }
        guard let testamentIndex = sameTestament.firstIndex(where: { $0.name == book }) else {
            return nil
        }
        let nextIndex = (testamentIndex + 1) % sameTestament.count
        return sameTestament[nextIndex].name
    }

    private func dominantUsageBucket() -> UsageBucket {
        let buckets = loadUsageBuckets()
        if let top = buckets.max(by: { $0.value < $1.value })?.key {
            return UsageBucket(rawValue: top) ?? bucket(for: Date())
        }
        return bucket(for: Date())
    }

    private func incrementUsageBucket(for date: Date) {
        var buckets = loadUsageBuckets()
        let key = bucket(for: date).rawValue
        buckets[key, default: 0] += 1
        defaults.set(buckets, forKey: Keys.usageBuckets)
    }

    private func bucket(for date: Date) -> UsageBucket {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .midday
        default:
            return .evening
        }
    }

    private func loadBookFrequency() -> [String: Int] {
        defaults.dictionary(forKey: Keys.bookFrequency) as? [String: Int] ?? [:]
    }

    private func saveBookFrequency(_ frequency: [String: Int]) {
        defaults.set(frequency, forKey: Keys.bookFrequency)
    }

    private func loadUsageBuckets() -> [String: Int] {
        defaults.dictionary(forKey: Keys.usageBuckets) as? [String: Int] ?? [:]
    }
}

enum PersonalizationAction {
    case resumeVerse(VerseReference)
    case openBook(String)
}

struct PersonalizationState {
    let primaryTitle: String
    let primaryBody: String
    let primaryActionTitle: String
    let primaryAction: PersonalizationAction
    let timeOfDayCopy: String
    let explorationCopy: String
    let explorationBook: String?

    static let empty = PersonalizationState(
        primaryTitle: "Continue your journey",
        primaryBody: "Open the Word and keep building your rhythm.",
        primaryActionTitle: "Open Bible",
        primaryAction: .openBook("Genesis"),
        timeOfDayCopy: "Set a small reading rhythm that fits your day.",
        explorationCopy: "Explore a new book today and build your pattern.",
        explorationBook: "Genesis"
    )
}

struct PersonalizationDebugSnapshot {
    let currentState: PersonalizationState
    let bookFrequency: [String: Int]
    let usageBuckets: [String: Int]
    let lastReadAt: Date?
    let lastReadReference: VerseReference?
}

extension PersonalizationService {
    func debugSnapshot() -> PersonalizationDebugSnapshot {
        let bookFrequency = defaults.dictionary(forKey: Keys.bookFrequency) as? [String: Int] ?? [:]
        let usageBuckets = defaults.dictionary(forKey: Keys.usageBuckets) as? [String: Int] ?? [:]

        let lastReadAtRaw = defaults.double(forKey: Keys.lastReadAt)
        let lastReadAt = lastReadAtRaw > 0 ? Date(timeIntervalSince1970: lastReadAtRaw) : nil

        var lastReadReference: VerseReference?
        if let data = defaults.data(forKey: Keys.lastReadReference),
           let decoded = try? JSONDecoder().decode(VerseReference.self, from: data) {
            lastReadReference = decoded
        }

        return PersonalizationDebugSnapshot(
            currentState: state,
            bookFrequency: bookFrequency,
            usageBuckets: usageBuckets,
            lastReadAt: lastReadAt,
            lastReadReference: lastReadReference
        )
    }
}
