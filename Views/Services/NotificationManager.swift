//
//  NotificationManager.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 3/25/25.
//

import Foundation
@preconcurrency import UserNotifications
import SwiftUI

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    @AppStorage("dailyVerseNotificationEnabled") var dailyVerseNotificationEnabled = false
    @AppStorage("dailyVerseNotificationTime") var dailyVerseNotificationTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @AppStorage("midweekMotivationEnabled") var midweekMotivationEnabled = false
    @AppStorage("weekendRefocusEnabled") var weekendRefocusEnabled = false
    @AppStorage("weekendRefocusDay") var weekendRefocusDay = "Sunday"
    @AppStorage("betaFeedbackEnabled") var betaFeedbackEnabled = true
    @AppStorage("featureDiscoveryEnabled") var featureDiscoveryEnabled = true
    @AppStorage("smartTimingEnabled") var smartTimingEnabled = false
    @AppStorage("gentleModeEnabled") var gentleModeEnabled = false
    @AppStorage("streakNudgeEnabled") var streakNudgeEnabled = false
    @AppStorage("hasOpenedBibleReader") var hasOpenedBibleReader = false
    @AppStorage("appLaunchCount") var appLaunchCount = 0
    @AppStorage("lastFeedbackRequestDate") var lastFeedbackRequestDate = Date.distantPast.timeIntervalSince1970
    @AppStorage("lastReadInContextPromptDate") var lastReadInContextPromptDate = Date.distantPast.timeIntervalSince1970
    @AppStorage("lastFeatureDiscoveryPushDate") var lastFeatureDiscoveryPushDate = Date.distantPast.timeIntervalSince1970

    private let calendar = Calendar.current
    private var usageTracker = AppUsageTracker()
    private var rateLimiter = NotificationRateLimiter()
    private var verseOfDaySchedulingTask: Task<Void, Never>?
    private static let verseOfDayIdentifierPrefix = "verse-of-day"
    private static let verseOfDayScheduleCount = 30

    enum MilestoneType {
        case finishedBook(book: String)
        case streak7
        case quizPersonalBest(score: Int)
    }

    private init() {
        checkAuthorizationStatus()
    }

    private var messageStyle: NotificationMessages.MessageStyle {
        gentleModeEnabled ? .gentle : .standard
    }

    private func debugLog(_ message: String) {
#if DEBUG
        print("DAILY-VERSE DEBUG: \(message)")
#endif
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.registerCategories()
                    self.scheduleAllNotifications()
                }
            }
            if let error {
                print("Push notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func markNotificationDelivered(at date: Date = Date()) {
        rateLimiter.recordNotificationSent(at: date)
    }

    func recordAppForeground(at date: Date = Date()) {
        usageTracker.recordAppOpen(at: date)
        scheduleStreakNudge(now: date)
    }

    func smartTimingDescription() -> String? {
        guard smartTimingEnabled else { return nil }
        guard let components = smartTimingComponents(referenceDate: Date()) else { return nil }
        guard let date = calendar.date(from: components) else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    private func registerCategories() {
        let readNowAction = UNNotificationAction(identifier: "READ_NOW", title: "Read Now", options: .foreground)
        let giveFeedbackAction = UNNotificationAction(identifier: "GIVE_FEEDBACK", title: "Give Feedback", options: .foreground)

        let categories: [UNNotificationCategory] = [
            UNNotificationCategory(identifier: "VERSE_OF_DAY", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "MIDWEEK_MOTIVATION", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "WEEKEND_REFOCUS", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "BETA_FEEDBACK", actions: [giveFeedbackAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "FEATURE_DISCOVERY", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "STREAK_NUDGE", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "READ_IN_CONTEXT", actions: [readNowAction], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "MILESTONE_CELEBRATION", actions: [readNowAction], intentIdentifiers: [], options: [])
        ]
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
    }

    func scheduleVerseOfDayNotification() {
        guard dailyVerseNotificationEnabled, isAuthorized else {
            cancelVerseOfDayNotifications()
            return
        }

        verseOfDaySchedulingTask?.cancel()
        verseOfDaySchedulingTask = Task {
            await replaceVerseOfDayNotifications(referenceDate: Date())
        }
    }

    func cancelVerseOfDayNotifications() {
        verseOfDaySchedulingTask?.cancel()
        Task {
            await removePendingVerseOfDayNotifications()
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func resetForAccountDeletion() {
        cancelAllNotifications()
        dailyVerseNotificationEnabled = false
        midweekMotivationEnabled = false
        weekendRefocusEnabled = false
        weekendRefocusDay = "Sunday"
        betaFeedbackEnabled = true
        featureDiscoveryEnabled = true
        smartTimingEnabled = false
        gentleModeEnabled = false
        streakNudgeEnabled = false
        hasOpenedBibleReader = false
        appLaunchCount = 0
        lastFeedbackRequestDate = Date.distantPast.timeIntervalSince1970
        lastReadInContextPromptDate = Date.distantPast.timeIntervalSince1970
        lastFeatureDiscoveryPushDate = Date.distantPast.timeIntervalSince1970
        isAuthorized = false
    }

    private func makeVerseOfDayNotificationContent(date: Date = Date()) async -> UNMutableNotificationContent {
        let settings = SettingsViewModel.shared
        let preferredVersion = VerseVersion(rawValue: settings.verseOfDayTranslation) ?? .aave
        let expectedReference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            testament: settings.verseOfDayTestament,
            book: settings.verseOfDayBook == "Any" ? nil : settings.verseOfDayBook,
            date: date,
            calendar: calendar
        )
        let selection = await VerseOfDayProvider.today(
            jesusSaidOnly: false,
            preferredVersion: preferredVersion,
            testament: settings.verseOfDayTestament,
            book: settings.verseOfDayBook == "Any" ? nil : settings.verseOfDayBook,
            date: date,
            calendar: calendar
        )

        let content = UNMutableNotificationContent()
        content.title = "For You Today"
        content.sound = .default
        content.categoryIdentifier = "VERSE_OF_DAY"

        if let selection,
           let reference = VerseOfDayProvider.reference(forVerseId: selection.verseId) {
            content.body = "\(selection.reference) - \(selection.excerpt)"
            applyVersePayload(reference, to: content)
            debugLog("notification content date=\(date) reference=\(selection.reference) version=\(selection.versionUsed.rawValue)")
        } else if let expectedReference {
            content.body = "\(expectedReference.displayString) - Tap to read today's verse."
            applyVersePayload(expectedReference, to: content)
            debugLog("notification content used reference-only fallback date=\(date) reference=\(expectedReference.displayString)")
        } else {
            content.body = NotificationMessages.message(for: .dailyVerse, style: messageStyle)
            debugLog("notification content fell back to generic daily message for date=\(date)")
        }

        return content
    }

    private func replaceVerseOfDayNotifications(referenceDate: Date) async {
        let center = UNUserNotificationCenter.current()
        await removePendingVerseOfDayNotifications(center: center)
        guard !Task.isCancelled else { return }

        let timeComponents = dailyVerseTimeComponents(referenceDate: referenceDate)
        let deliveryDates = DailyVerseNotificationPlan.deliveryDates(
            after: referenceDate,
            timeComponents: timeComponents,
            calendar: calendar,
            count: Self.verseOfDayScheduleCount
        )

        for deliveryDate in deliveryDates {
            let content = await makeVerseOfDayNotificationContent(date: deliveryDate)
            guard !Task.isCancelled else { return }
            let triggerComponents = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: deliveryDate
            )
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: triggerComponents,
                repeats: false
            )
            let identifier = DailyVerseNotificationPlan.identifier(
                for: deliveryDate,
                calendar: calendar,
                prefix: Self.verseOfDayIdentifierPrefix
            )
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Error scheduling verse of day notification for \(deliveryDate): \(error)")
            }
        }
    }

    private func removePendingVerseOfDayNotifications(
        center: UNUserNotificationCenter = .current()
    ) async {
        let requests = await center.pendingNotificationRequests()
        let identifiers = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(Self.verseOfDayIdentifierPrefix) }
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func applyVersePayload(
        _ reference: VerseReference,
        to content: UNMutableNotificationContent
    ) {
        content.userInfo = [
            "book": reference.book,
            "chapter": reference.chapter,
            "verse": reference.verse
        ]
    }

    func scheduleMidweekMotivation() {
        guard midweekMotivationEnabled, isAuthorized else {
            cancelNotifications(withIdentifiers: ["midweek-motivation"])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Midweek Motivation"
        content.body = NotificationMessages.message(for: .midweekMotivation, style: messageStyle)
        content.sound = .default
        content.categoryIdentifier = "MIDWEEK_MOTIVATION"

        var components = DateComponents()
        components.weekday = 4
        components.hour = 12
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "midweek-motivation", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling midweek motivation: \(error)")
            }
        }
    }

    func scheduleWeekendRefocus() {
        guard weekendRefocusEnabled, isAuthorized else {
            cancelNotifications(withIdentifiers: ["weekend-refocus"])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Weekend Refocus"
        content.body = NotificationMessages.message(for: .weekendRefocus, style: messageStyle)
        content.sound = .default
        content.categoryIdentifier = "WEEKEND_REFOCUS"

        var components = DateComponents()
        components.weekday = weekendRefocusDay == "Sunday" ? 1 : 7
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekend-refocus", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling weekend refocus: \(error)")
            }
        }
    }

    func checkAndScheduleBetaFeedback(now: Date = Date()) {
        guard betaFeedbackEnabled, isAuthorized else { return }
        guard rateLimiter.canScheduleOneOffToday(referenceDate: now) else { return }

        let fourteenDays: TimeInterval = 14 * 24 * 60 * 60
        let currentTime = now.timeIntervalSince1970
        guard appLaunchCount >= 4, (currentTime - lastFeedbackRequestDate) > fourteenDays else { return }

        let content = UNMutableNotificationContent()
        content.title = "App Feedback"
        content.body = NotificationMessages.message(for: .betaFeedback, style: messageStyle)
        content.sound = .default
        content.categoryIdentifier = "BETA_FEEDBACK"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 24 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "beta-feedback-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                print("Error scheduling beta feedback: \(error)")
                return
            }
            DispatchQueue.main.async {
                self?.lastFeedbackRequestDate = currentTime
            }
        }
    }

    func scheduleFeatureDiscovery(feature: String, description: String) {
        guard featureDiscoveryEnabled, isAuthorized else { return }
        guard hasOpenedBibleReader else { return }
        guard appLaunchCount >= 12 else { return }

        let now = Date()
        let cooldown: TimeInterval = 45 * 24 * 60 * 60
        guard now.timeIntervalSince1970 - lastFeatureDiscoveryPushDate >= cooldown else { return }
        guard rateLimiter.canScheduleOneOffToday(referenceDate: now) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Feature Discovery"
        if feature == "Commentary" {
            content.body = NotificationMessages.getCommentaryNotification(style: messageStyle)
        } else {
            let label = description.isEmpty ? feature : description
            content.body = NotificationMessages.message(for: .featureDiscovery(feature: label), style: messageStyle)
        }
        content.sound = .default
        content.categoryIdentifier = "FEATURE_DISCOVERY"
        content.userInfo = ["feature": feature]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 48 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "feature-discovery-\(feature.lowercased().replacingOccurrences(of: " ", with: "-"))",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                print("Error scheduling feature discovery: \(error)")
                return
            }
            DispatchQueue.main.async {
                self?.lastFeatureDiscoveryPushDate = now.timeIntervalSince1970
            }
        }
    }

    func cancelNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleAllNotifications() {
        scheduleVerseOfDayNotification()
        scheduleMidweekMotivation()
        scheduleWeekendRefocus()
        scheduleStreakNudge()
        checkAndScheduleBetaFeedback()
        if !featureDiscoveryEnabled {
            cancelNotifications(withIdentifiers: ["feature-discovery-commentary", "feature-discovery-compare-translations", "feature-discovery-quiz"])
        }
    }

    func incrementAppLaunchCount() {
        appLaunchCount += 1
        checkAndScheduleBetaFeedback()
    }

    func scheduleStreakNudge() {
        scheduleStreakNudge(now: Date())
    }

    private func scheduleStreakNudge(now: Date) {
        guard streakNudgeEnabled, isAuthorized else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        guard ReadingProgressService.shared.currentStreak >= 3 else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        let dailyGoal = max(1, ReadingProgressService.shared.dailyGoalVerses)
        guard ReadingProgressService.shared.versesReadToday < dailyGoal else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        guard !dailyVerseNotificationEnabled else {
            // Respect one-per-day by default when daily verse is active.
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        let hasSentToday = rateLimiter.hasNotificationSentToday(referenceDate: now)
        guard !hasSentToday else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }
        guard let baseline = nudgeBaselineDate(now: now),
              StreakNudgePolicy.shouldSend(
                currentStreak: ReadingProgressService.shared.currentStreak,
                versesReadToday: ReadingProgressService.shared.versesReadToday,
                dailyGoalVerses: dailyGoal,
                now: now,
                baselineDate: baseline,
                hasNotificationSentToday: hasSentToday
              ) else {
            cancelNotifications(withIdentifiers: ["streak-nudge"])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Reading Reminder"
        content.body = NotificationMessages.message(for: .streakNudge, style: messageStyle)
        content.sound = .default
        content.categoryIdentifier = "STREAK_NUDGE"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-nudge", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                print("Error scheduling streak nudge: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.rateLimiter.recordNotificationSent(at: now)
                }
            }
        }
    }

    func scheduleReadInContextNudge() {
        guard isAuthorized else { return }
        guard hasOpenedBibleReader else { return }
        guard rateLimiter.canScheduleOneOffToday(referenceDate: Date()) else { return }

        let now = Date().timeIntervalSince1970
        let oneDay: TimeInterval = 24 * 60 * 60
        guard now - lastReadInContextPromptDate >= oneDay else { return }

        let content = UNMutableNotificationContent()
        content.title = "Read in Context"
        content.body = NotificationMessages.message(for: .readInContext, style: messageStyle)
        content.sound = .default
        content.categoryIdentifier = "READ_IN_CONTEXT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "read-in-context", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                print("Error scheduling read-in-context: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.lastReadInContextPromptDate = now
                }
            }
        }
    }

    func scheduleMilestoneCelebration(_ milestone: MilestoneType, now: Date = Date()) {
        guard isAuthorized else { return }
        guard rateLimiter.canSendCelebration(referenceDate: now) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Milestone"
        content.sound = .default
        content.categoryIdentifier = "MILESTONE_CELEBRATION"

        switch milestone {
        case .finishedBook(let book):
            content.body = NotificationMessages.message(for: .celebrationBookFinished(book: book), style: .milestone)
        case .streak7:
            content.body = NotificationMessages.message(for: .celebrationStreak7, style: .milestone)
        case .quizPersonalBest(let score):
            content.body = NotificationMessages.message(for: .celebrationQuizPersonalBest(score: score), style: .milestone)
        }

        let dayStamp = Self.dayStampFormatter.string(from: now)
        let identifier: String
        switch milestone {
        case .finishedBook:
            identifier = "milestone-book-\(dayStamp)"
        case .streak7:
            identifier = "milestone-streak-\(dayStamp)"
        case .quizPersonalBest:
            identifier = "milestone-quiz-\(dayStamp)"
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error {
                print("Error scheduling milestone notification: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.rateLimiter.recordCelebrationSent(at: now)
                }
            }
        }
    }

    func markBibleReaderOpened() {
        hasOpenedBibleReader = true
    }

    private func nudgeBaselineDate(now: Date) -> Date? {
        let baselineComponents: DateComponents
        if smartTimingEnabled, let smart = smartTimingComponents(referenceDate: now) {
            baselineComponents = smart
        } else {
            baselineComponents = calendar.dateComponents([.hour, .minute], from: dailyVerseNotificationTime)
        }

        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = baselineComponents.hour
        todayComponents.minute = baselineComponents.minute

        return calendar.date(from: todayComponents)
    }

    private func dailyVerseTimeComponents(referenceDate: Date) -> DateComponents {
        let manual = calendar.dateComponents([.hour, .minute], from: dailyVerseNotificationTime)
        guard smartTimingEnabled else { return manual }

        if !rateLimiter.canAdjustSmartTiming(referenceDate: referenceDate),
           let cached = rateLimiter.smartTimingComponents() {
            return cached
        }

        guard let computed = smartTimingComponents(referenceDate: referenceDate) else {
            return manual
        }

        let clamped = clampToReasonableWindow(components: computed)
        rateLimiter.recordSmartTimingAdjustment(components: clamped, at: referenceDate)
        return clamped
    }

    private func smartTimingComponents(referenceDate: Date) -> DateComponents? {
        if let computed = usageTracker.typicalOpenTime(referenceDate: referenceDate, minimumDistinctDays: 4) {
            return computed
        }
        return rateLimiter.smartTimingComponents()
    }

    private func clampToReasonableWindow(components: DateComponents) -> DateComponents {
        let hour = min(21, max(7, components.hour ?? 8))
        let minute = min(59, max(0, components.minute ?? 0))
        var output = DateComponents()
        output.hour = hour
        output.minute = minute
        return output
    }

    private static let dayStampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct AppUsageTracker {
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let key = "notifications.appOpenTimestamps"
    private let maxEntries = 14

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    func recordAppOpen(at date: Date) {
        var dates = recordedDates()
        dates.append(date)
        dates = Array(dates.sorted().suffix(maxEntries))
        save(dates)
    }

    func typicalOpenTime(referenceDate: Date, minimumDistinctDays: Int) -> DateComponents? {
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: referenceDate)) ?? referenceDate
        let recent = recordedDates().filter { $0 >= sevenDaysAgo }
        guard !recent.isEmpty else { return nil }

        var earliestByDay: [Date: Date] = [:]
        for date in recent {
            let day = calendar.startOfDay(for: date)
            if let existing = earliestByDay[day] {
                if date < existing {
                    earliestByDay[day] = date
                }
            } else {
                earliestByDay[day] = date
            }
        }

        let distinctDays = earliestByDay.keys.count
        guard distinctDays >= minimumDistinctDays else { return nil }

        let minutes = earliestByDay.values.map {
            let parts = calendar.dateComponents([.hour, .minute], from: $0)
            return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        }.sorted()

        guard let medianMinute = minutes[safe: minutes.count / 2] else { return nil }
        var components = DateComponents()
        components.hour = medianMinute / 60
        components.minute = medianMinute % 60
        return components
    }

    private func recordedDates() -> [Date] {
        let raw = defaults.array(forKey: key) as? [TimeInterval] ?? []
        return raw.map(Date.init(timeIntervalSince1970:))
    }

    private func save(_ dates: [Date]) {
        defaults.set(dates.map(\.timeIntervalSince1970), forKey: key)
    }
}

struct NotificationRateLimiter {
    private let defaults: UserDefaults
    private let calendar: Calendar

    private enum Keys {
        static let lastNotificationSentAt = "notifications.lastNotificationSentAt"
        static let lastCelebrationSentAt = "notifications.lastCelebrationSentAt"
        static let lastSmartTimingAdjustmentAt = "notifications.lastSmartTimingAdjustmentAt"
        static let smartTimingHour = "notifications.smartTimingHour"
        static let smartTimingMinute = "notifications.smartTimingMinute"
    }

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    func hasNotificationSentToday(referenceDate: Date) -> Bool {
        guard let last = date(forKey: Keys.lastNotificationSentAt) else { return false }
        return calendar.isDate(last, inSameDayAs: referenceDate)
    }

    func canScheduleOneOffToday(referenceDate: Date) -> Bool {
        !hasNotificationSentToday(referenceDate: referenceDate)
    }

    func canSendCelebration(referenceDate: Date) -> Bool {
        guard !hasNotificationSentToday(referenceDate: referenceDate) else { return false }
        guard let lastCelebration = date(forKey: Keys.lastCelebrationSentAt) else { return true }
        return referenceDate.timeIntervalSince(lastCelebration) >= 7 * 24 * 60 * 60
    }

    func recordNotificationSent(at date: Date) {
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastNotificationSentAt)
    }

    func recordCelebrationSent(at date: Date) {
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastCelebrationSentAt)
        recordNotificationSent(at: date)
    }

    func canAdjustSmartTiming(referenceDate: Date) -> Bool {
        guard let last = date(forKey: Keys.lastSmartTimingAdjustmentAt) else { return true }
        return referenceDate.timeIntervalSince(last) >= 7 * 24 * 60 * 60
    }

    func recordSmartTimingAdjustment(components: DateComponents, at date: Date) {
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastSmartTimingAdjustmentAt)
        defaults.set(components.hour ?? 8, forKey: Keys.smartTimingHour)
        defaults.set(components.minute ?? 0, forKey: Keys.smartTimingMinute)
    }

    func smartTimingComponents() -> DateComponents? {
        let hour = defaults.object(forKey: Keys.smartTimingHour) as? Int
        let minute = defaults.object(forKey: Keys.smartTimingMinute) as? Int
        guard let hour, let minute else { return nil }
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }

    private func date(forKey key: String) -> Date? {
        let value = defaults.double(forKey: key)
        guard value > 0 else { return nil }
        return Date(timeIntervalSince1970: value)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

struct StreakNudgePolicy {
    static func shouldSend(
        currentStreak: Int,
        versesReadToday: Int,
        dailyGoalVerses: Int,
        now: Date,
        baselineDate: Date,
        hasNotificationSentToday: Bool
    ) -> Bool {
        guard currentStreak >= 3 else { return false }
        guard versesReadToday < max(1, dailyGoalVerses) else { return false }
        guard !hasNotificationSentToday else { return false }
        guard let threshold = Calendar.current.date(byAdding: .hour, value: 2, to: baselineDate) else { return false }
        return now >= threshold
    }
}

struct DailyVerseNotificationPlan {
    static func deliveryDates(
        after referenceDate: Date,
        timeComponents: DateComponents,
        calendar: Calendar,
        count: Int
    ) -> [Date] {
        guard count > 0 else { return [] }

        var matchingComponents = DateComponents()
        matchingComponents.hour = min(23, max(0, timeComponents.hour ?? 8))
        matchingComponents.minute = min(59, max(0, timeComponents.minute ?? 0))

        guard let firstDelivery = calendar.nextDate(
            after: referenceDate,
            matching: matchingComponents,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        ) else {
            return []
        }

        return (0..<count).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: firstDelivery)
        }
    }

    static func identifier(
        for deliveryDate: Date,
        calendar: Calendar,
        prefix: String = "verse-of-day"
    ) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: deliveryDate)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%@-%04d-%02d-%02d", prefix, year, month, day)
    }
}
