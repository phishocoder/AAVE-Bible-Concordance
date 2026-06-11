import XCTest
@testable import AAVE_Bible_Concordance

@MainActor
final class LeaderboardTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testMonthIntervalUsesCalendarMonthBoundaries() throws {
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 2, day: 18, hour: 12)))
        let interval = LeaderboardPeriod.month.dateInterval(containing: date, calendar: calendar)

        XCTAssertEqual(calendar.dateComponents([.year, .month, .day], from: interval.start), DateComponents(year: 2026, month: 2, day: 1))
        XCTAssertEqual(calendar.dateComponents([.year, .month, .day], from: interval.end), DateComponents(year: 2026, month: 3, day: 1))
    }

    func testBestEntryPerUserKeepsHighestScore() {
        let older = Date(timeIntervalSince1970: 100)
        let newer = Date(timeIntervalSince1970: 200)
        let runs = [
            LeaderboardEntry(userID: "reader", score: 7, username: "Reader", timestamp: newer),
            LeaderboardEntry(userID: "reader", score: 9, username: "Reader", timestamp: older)
        ]

        let results = LeaderboardViewModel.bestEntriesPerUser(from: runs, limit: 10)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 9)
    }

    func testEqualScoresUseNewestRunThenStableUserIDOrdering() {
        let sameTime = Date(timeIntervalSince1970: 100)
        let newer = Date(timeIntervalSince1970: 200)
        let runs = [
            LeaderboardEntry(userID: "charlie", score: 10, username: "Charlie", timestamp: sameTime),
            LeaderboardEntry(userID: "bravo", score: 10, username: "Bravo", timestamp: newer),
            LeaderboardEntry(userID: "alpha", score: 10, username: "Alpha", timestamp: sameTime)
        ]

        let results = LeaderboardViewModel.bestEntriesPerUser(from: runs, limit: 10)

        XCTAssertEqual(results.map(\.userID), ["bravo", "alpha", "charlie"])
    }

    func testLeaderboardLimitAppliesAfterDeduplicatingUsers() {
        let runs = (0..<12).flatMap { index in
            [
                LeaderboardEntry(userID: "user-\(index)", score: index, username: nil, timestamp: .distantPast),
                LeaderboardEntry(userID: "user-\(index)", score: index - 1, username: nil, timestamp: .distantFuture)
            ]
        }

        let results = LeaderboardViewModel.bestEntriesPerUser(from: runs, limit: 10)

        XCTAssertEqual(results.count, 10)
        XCTAssertEqual(results.map(\.score), Array((2...11).reversed()))
    }
}
