import XCTest
@testable import AAVE_Bible_Concordance

final class AAVE_Bible_ConcordanceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private var calendar: Calendar!

    override func setUp() {
        super.setUp()
        suiteName = "tests.notifications.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        calendar = nil
        super.tearDown()
    }

    func testTypicalOpenTimeUsesMedianAcrossDistinctDays() {
        let tracker = AppUsageTracker(defaults: defaults, calendar: calendar)

        tracker.recordAppOpen(at: date(2026, 2, 10, 8, 20))
        tracker.recordAppOpen(at: date(2026, 2, 11, 8, 30))
        tracker.recordAppOpen(at: date(2026, 2, 12, 8, 0))
        tracker.recordAppOpen(at: date(2026, 2, 13, 8, 10))
        tracker.recordAppOpen(at: date(2026, 2, 13, 18, 0)) // same day later; should not affect median

        let referenceDate = date(2026, 2, 14, 12, 0)
        let result = tracker.typicalOpenTime(referenceDate: referenceDate, minimumDistinctDays: 4)

        XCTAssertEqual(result?.hour, 8)
        XCTAssertEqual(result?.minute, 20)
    }

    func testRateLimiterBlocksSameDayOneOffAndLimitsCelebrationWeekly() {
        let limiter = NotificationRateLimiter(defaults: defaults, calendar: calendar)
        let now = date(2026, 2, 14, 11, 0)

        XCTAssertTrue(limiter.canScheduleOneOffToday(referenceDate: now))
        limiter.recordNotificationSent(at: now)
        XCTAssertFalse(limiter.canScheduleOneOffToday(referenceDate: now))

        let futureDay = date(2026, 2, 15, 11, 0)
        XCTAssertTrue(limiter.canSendCelebration(referenceDate: futureDay))
        limiter.recordCelebrationSent(at: futureDay)

        let sixDaysLater = date(2026, 2, 21, 11, 0)
        XCTAssertFalse(limiter.canSendCelebration(referenceDate: sixDaysLater))

        let eightDaysLater = date(2026, 2, 23, 11, 0)
        XCTAssertTrue(limiter.canSendCelebration(referenceDate: eightDaysLater))
    }

    func testStreakNudgePolicyOnlyTriggersWhenAllConditionsMatch() {
        let baseline = date(2026, 2, 14, 8, 0)
        let afterThreshold = date(2026, 2, 14, 10, 5)

        XCTAssertTrue(
            StreakNudgePolicy.shouldSend(
                currentStreak: 3,
                versesReadToday: 0,
                dailyGoalVerses: 10,
                now: afterThreshold,
                baselineDate: baseline,
                hasNotificationSentToday: false
            )
        )

        XCTAssertFalse(
            StreakNudgePolicy.shouldSend(
                currentStreak: 2,
                versesReadToday: 0,
                dailyGoalVerses: 10,
                now: afterThreshold,
                baselineDate: baseline,
                hasNotificationSentToday: false
            )
        )

        XCTAssertFalse(
            StreakNudgePolicy.shouldSend(
                currentStreak: 4,
                versesReadToday: 10,
                dailyGoalVerses: 10,
                now: afterThreshold,
                baselineDate: baseline,
                hasNotificationSentToday: false
            )
        )

        XCTAssertFalse(
            StreakNudgePolicy.shouldSend(
                currentStreak: 4,
                versesReadToday: 0,
                dailyGoalVerses: 10,
                now: date(2026, 2, 14, 9, 30),
                baselineDate: baseline,
                hasNotificationSentToday: false
            )
        )

        XCTAssertFalse(
            StreakNudgePolicy.shouldSend(
                currentStreak: 4,
                versesReadToday: 0,
                dailyGoalVerses: 10,
                now: afterThreshold,
                baselineDate: baseline,
                hasNotificationSentToday: true
            )
        )
    }

    func testVerseOfDayProviderChangesByCalendarDay() {
        let firstDay = date(2026, 2, 14, 8, 0)
        let nextDay = date(2026, 2, 15, 8, 0)

        let firstReference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            date: firstDay,
            calendar: calendar
        )
        let nextReference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            date: nextDay,
            calendar: calendar
        )

        XCTAssertNotEqual(firstReference, nextReference)
    }

    func testVerseOfDayProviderKeepsSameVerseWithinCalendarDay() {
        let morning = date(2026, 2, 14, 8, 0)
        let evening = date(2026, 2, 14, 20, 30)

        let morningReference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            date: morning,
            calendar: calendar
        )
        let eveningReference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            date: evening,
            calendar: calendar
        )

        XCTAssertEqual(morningReference, eveningReference)
    }

    func testVerseOfDayProviderHonorsBookFilterWhenAvailable() {
        let reference = VerseOfDayProvider.reference(
            jesusSaidOnly: false,
            book: "Romans",
            date: date(2026, 2, 14, 8, 0),
            calendar: calendar
        )

        XCTAssertEqual(reference?.book, "Romans")
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return calendar.date(from: components) ?? Date()
    }
}
