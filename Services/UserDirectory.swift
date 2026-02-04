import Foundation
import FirebaseFirestore

final class UserDirectory {
    static let shared = UserDirectory()

    private let db = Firestore.firestore()
    private var cache: [String: String] = [:]

    private init() {}

    func resolveDisplayName(for uid: String, completion: @escaping (String) -> Void) {
        if let cached = cache[uid] {
            completion(cached)
            return
        }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            let data = snapshot?.data()
            let name = (data?["displayName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolved = (name?.isEmpty == false) ? name! : Self.fallbackName(for: uid)
            self?.cache[uid] = resolved
            completion(resolved)
        }
    }

    static func fallbackName(for uid: String) -> String {
        let shortID = uid.prefix(6)
        return "User \(shortID)"
    }
}
