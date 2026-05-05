import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AccountDeletionService {
    static let shared = AccountDeletionService()

    enum AccountDeletionError: LocalizedError, Equatable {
        case missingUser
        case requiresRecentLogin
        case networkFailure
        case permissionDenied
        case partialDeletion
        case unknown(String)

        var errorDescription: String? {
            switch self {
            case .missingUser:
                return "We couldn’t find an active account to delete."
            case .requiresRecentLogin:
                return "Apple needs to confirm this account before deletion can finish."
            case .networkFailure:
                return "We couldn’t reach the server. Check your connection and try again."
            case .permissionDenied:
                return "The app wasn’t allowed to delete your account data. Please try again or contact support."
            case .partialDeletion:
                return "Some account data was removed, but we couldn’t finish deleting the sign-in record. Sign in again and retry to complete deletion."
            case .unknown(let message):
                return message
            }
        }
    }

    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let notificationManager = NotificationManager.shared
    private let readingProgress = ReadingProgressService.shared
    private let userDataManager = UserDataManager.shared
    private let profilePreferences = UserProfilePreferences.shared
    private let highlightManager = HighlightManager.shared
    private let bookmarks = Bookmarks.shared

    private init() {}

    func deleteCurrentUserAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountDeletionError.missingUser
        }

        do {
            try await deleteUserFirestoreData(uid: user.uid)
        } catch {
            throw mapFirestoreError(error)
        }

        do {
            try await deleteFirebaseAuthUser(user)
        } catch {
            let mapped = mapAuthError(error)
            throw mapped
        }

        clearLocalUserData()
        AppleAuthManager.shared.handleAccountDeleted(showOnboarding: false)
        FirebaseAuthManager.shared.handleAccountDeleted()
    }

    func deleteUserFirestoreData(uid: String) async throws {
        try await deleteKnownUserSubcollections(uid: uid)
        try await deleteQuizScores(uid: uid)
        try await deleteUserDocument(uid: uid)
    }

    func deleteFirebaseAuthUser(_ user: User) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func deleteUserDocument(uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        let snapshot = try await fetchDocument(userRef)
        guard snapshot.exists else { return }
        try await deleteDocument(userRef)
    }

    private func deleteQuizScores(uid: String) async throws {
        let query = db.collection("quizScores").whereField("userID", isEqualTo: uid)
        try await deleteDocuments(matching: query)
    }

    private func deleteKnownUserSubcollections(uid: String) async throws {
        let subcollections = [
            "bookmarks",
            "highlights",
            "notes",
            "notificationPreferences",
            "readingProgress",
            "quizScores",
            "preferences"
        ]

        let userRef = db.collection("users").document(uid)
        for collection in subcollections {
            try await deleteDocuments(matching: userRef.collection(collection))
        }
    }

    private func deleteDocuments(matching query: Query) async throws {
        let snapshot = try await fetchDocuments(query)
        guard snapshot.documents.isEmpty == false else { return }

        for chunk in snapshot.documents.chunked(into: 400) {
            let batch = db.batch()
            chunk.forEach { batch.deleteDocument($0.reference) }
            try await commit(batch)
        }
    }

    private func clearLocalUserData() {
        userDataManager.clearAllUserData()
        bookmarks.clearAllBookmarks()
        highlightManager.clearHighlights()
        readingProgress.resetForAccountDeletion()
        PersonalizationService.shared.resetForAccountDeletion()
        notificationManager.resetForAccountDeletion()
        profilePreferences.resetForAccountDeletion()

        userDefaults.set(false, forKey: "lockScreenDailyVerseEnabled")
        userDefaults.set(false, forKey: "lockScreenJesusSaidEnabled")
        userDefaults.set(VerseVersion.aave.rawValue, forKey: "lockScreenVerseVersion")
        userDefaults.set(AppTab.home.rawValue, forKey: "selectedTab")
    }

    private func fetchDocuments(_ query: Query) async throws -> QuerySnapshot {
        try await withCheckedThrowingContinuation { continuation in
            query.getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: AccountDeletionError.unknown("The server returned an empty response while deleting account data."))
                }
            }
        }
    }

    private func fetchDocument(_ reference: DocumentReference) async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            reference.getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: AccountDeletionError.unknown("The server returned an empty user record response."))
                }
            }
        }
    }

    private func deleteDocument(_ reference: DocumentReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func commit(_ batch: WriteBatch) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            batch.commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func mapAuthError(_ error: Error) -> AccountDeletionError {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(nsError.localizedDescription)
        }

        switch code {
        case .requiresRecentLogin:
            return .requiresRecentLogin
        case .networkError:
            return .networkFailure
        case .userNotFound, .invalidUserToken, .userTokenExpired:
            return .missingUser
        default:
            return .unknown(nsError.localizedDescription)
        }
    }

    private func mapFirestoreError(_ error: Error) -> AccountDeletionError {
        let nsError = error as NSError

        if nsError.domain == FirestoreErrorDomain {
            switch nsError.code {
            case 7:
                return .permissionDenied
            case 4, 14:
                return .networkFailure
            default:
                return .unknown(nsError.localizedDescription)
            }
        }

        return .unknown(nsError.localizedDescription)
    }

    private func debugLog(_ message: String) {
#if DEBUG
        print("[AccountDeletion] \(message)")
#endif
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }

        var chunks: [[Element]] = []
        chunks.reserveCapacity((count / size) + 1)

        var index = startIndex
        while index < endIndex {
            let nextIndex = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(Array(self[index..<nextIndex]))
            index = nextIndex
        }

        return chunks
    }
}
