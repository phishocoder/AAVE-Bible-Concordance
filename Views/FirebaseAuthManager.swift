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
    
    @Published var userID: String?

    private init() {
        signInAnonymously()
    }

    func signInAnonymously() {
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
            print("Already signed in with UID: \(currentUser.uid)")
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Firebase auth error: \(error.localizedDescription)")
                return
            }

            if let user = result?.user {
                self.userID = user.uid
                print("✅ Signed in anonymously with UID: \(user.uid)")
            }
        }
    }
}
