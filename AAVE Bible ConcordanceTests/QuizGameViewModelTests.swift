import XCTest
@testable import AAVE_Bible_Concordance

final class QuizGameViewModelTests: XCTestCase {
    func testSubmitScoreRequiresDisplayNameBeforeLogging() {
        let viewModel = QuizGameViewModel(autostartTimer: false)
        var didFetchBestScore = false
        var didLogScore = false

        viewModel.submitScoreIfPossible(
            currentUserID: "test-user",
            storedDisplayName: "   ",
            fetchBestScore: { _, _ in
                didFetchBestScore = true
            },
            logScore: { _, _ in
                didLogScore = true
            }
        )

        XCTAssertTrue(viewModel.requiresLeaderboardDisplayName)
        XCTAssertFalse(didFetchBestScore)
        XCTAssertFalse(didLogScore)
    }

    func testSubmitScoreLogsImmediatelyWhenDisplayNameExists() {
        let viewModel = QuizGameViewModel(autostartTimer: false)
        let fetchExpectation = expectation(description: "fetchBestScore called")
        var loggedPayload: (userID: String, score: Int)?

        viewModel.submitScoreIfPossible(
            currentUserID: "test-user",
            storedDisplayName: "Phil",
            fetchBestScore: { _, completion in
                fetchExpectation.fulfill()
                completion(4)
            },
            logScore: { userID, score in
                loggedPayload = (userID, score)
            }
        )

        wait(for: [fetchExpectation], timeout: 1.0)

        XCTAssertFalse(viewModel.requiresLeaderboardDisplayName)
        XCTAssertEqual(loggedPayload?.userID, "test-user")
        XCTAssertEqual(loggedPayload?.score, 0)
    }

    func testSubmitScoreRequiresRealNameWhenPlaceholderIsStored() {
        let viewModel = QuizGameViewModel(autostartTimer: false)
        var didFetchBestScore = false
        var didLogScore = false

        viewModel.submitScoreIfPossible(
            currentUserID: "test-user",
            storedDisplayName: "Reader 1234",
            fetchBestScore: { _, _ in
                didFetchBestScore = true
            },
            logScore: { _, _ in
                didLogScore = true
            }
        )

        XCTAssertTrue(viewModel.requiresLeaderboardDisplayName)
        XCTAssertFalse(didFetchBestScore)
        XCTAssertFalse(didLogScore)
    }
}
