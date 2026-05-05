//
//  FirebaseAuthManager.swift
//  AAVE Bible Concordance
//
//  Created by Phil Shobo on 4/24/25.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager: ObservableObject {
    static let shared = FirebaseAuthManager()

    private let suppressAnonymousAuthKey = "suppressAnonymousAuthAfterDeletion"
    
    @Published var userID: String?

    private init() {
        // Don’t call signInAnonymously() here.
        // We'll manually call it on app launch inside ContentView.
    }

    func signInAnonymously() {
        guard shouldAllowAnonymousAuth else {
            self.userID = nil
#if DEBUG
            print("⚠️ Anonymous auth is currently suppressed.")
#endif
            return
        }

        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
            print("✅ Already signed in with UID: \(currentUser.uid)")
            return
        }

        Auth.auth().signInAnonymously { [weak self] result, error in
            if let error = error {
                print("❌ Firebase anonymous auth error: \(error.localizedDescription)")
                return
            }

            if let user = result?.user {
                DispatchQueue.main.async {
                    self?.userID = user.uid
                    print("✅ Signed in anonymously with UID: \(user.uid)")
                }
            }
        }
    }

    func handleAccountDeleted() {
        userID = nil
        UserDefaults.standard.set(true, forKey: suppressAnonymousAuthKey)
    }

    func resumeAnonymousAuth() {
        UserDefaults.standard.set(false, forKey: suppressAnonymousAuthKey)
    }

    private var shouldAllowAnonymousAuth: Bool {
        UserDefaults.standard.bool(forKey: suppressAnonymousAuthKey) == false
    }
}
