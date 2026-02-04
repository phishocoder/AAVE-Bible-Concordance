import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import CryptoKit
import Security

class AppleAuthManager: NSObject, ObservableObject {
    static let shared = AppleAuthManager()

    @Published var isSignedIn = false
    @Published var displayName: String?
    @Published var userID: String?
    @Published var needsUsernamePrompt = false
    @Published var pendingUserID: String?

    private let db = Firestore.firestore()
    private var currentNonce: String?
    private let keychain = KeychainHelper.shared
    private let keychainService = "AAVEBibleAppleSignIn"
    private let keychainAccount = "appleUserID"
    private let displayNameKey = "displayName"
    
    // Generate a random nonce for authentication
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Hashed nonce for Apple authentication
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    /// Attempt to restore a previous Apple sign-in from Keychain and validate credential state.
    func restorePreviousSignIn() {
        // If Firebase already has a user session, surface it immediately.
        if let current = Auth.auth().currentUser {
            DispatchQueue.main.async {
                self.userID = current.uid
                let storedName = UserDefaults.standard.string(forKey: "displayName")?.trimmingCharacters(in: .whitespacesAndNewlines)
                let resolvedName: String? = {
                    if let storedName, !storedName.isEmpty { return storedName }
                    if let currentName = current.displayName, !currentName.isEmpty { return currentName }
                    let fallback = self.generateDefaultDisplayName()
                    UserDefaults.standard.set(fallback, forKey: self.displayNameKey)
                    return fallback
                }()
                self.displayName = resolvedName
                self.isSignedIn = true
            }
            let nameForDoc = UserDefaults.standard.string(forKey: displayNameKey) ?? current.displayName ?? generateDefaultDisplayName()
            ensureUserDocument(uid: current.uid, displayName: nameForDoc)
        }
        
        guard let savedAppleID = keychain.read(service: keychainService, account: keychainAccount) else { return }
        
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: savedAppleID) { [weak self] state, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self.userID = self.userID ?? savedAppleID
                    self.isSignedIn = true
                case .revoked, .notFound, .transferred:
                    self.keychain.delete(service: self.keychainService, account: self.keychainAccount)
                    self.isSignedIn = false
                    self.userID = nil
                default:
                    break
                }
            }
        }
    }

    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAuthorizationResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                handleAppleCredential(appleIDCredential)
            } else {
                print("❌ Apple Sign-In returned unexpected credential type.")
            }
        case .failure(let error):
            print("❌ Apple Sign-In failed: \(error.localizedDescription)")
        }
    }

    func startSignInWithAppleFlow() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        configureAppleRequest(request)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }

        keychain.delete(service: keychainService, account: keychainAccount)
        UserDefaults.standard.set("", forKey: "displayName")
        UserDefaults.standard.set(false, forKey: "didCompleteOnboarding")
        UserDefaults.standard.set(AppTab.home.rawValue, forKey: "selectedTab")

        DispatchQueue.main.async {
            self.isSignedIn = false
            self.displayName = nil
            self.userID = nil
            self.needsUsernamePrompt = false
            self.pendingUserID = nil
        }

        NotificationCenter.default.post(name: Notification.Name("ShowProfile"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("ShowOnboarding"), object: nil)
    }

    private func handleAppleCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        guard let nonce = currentNonce else {
            print("❌ Invalid state: A login callback was received, but no login request was sent.")
            return
        }

        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            print("❌ Failed to get identity token from Apple.")
            return
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                   idToken: tokenString,
                                                   rawNonce: nonce)

        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                print("❌ Firebase sign-in failed: \(error.localizedDescription)")
                return
            }

            guard let user = authResult?.user else { return }
            let givenName = appleIDCredential.fullName?.givenName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let storedName = UserDefaults.standard.string(forKey: "displayName")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let resolvedName: String = {
                if !givenName.isEmpty { return givenName }
                if !storedName.isEmpty { return storedName }
                return self?.generateDefaultDisplayName() ?? "Reader"
            }()
            UserDefaults.standard.set(resolvedName, forKey: self?.displayNameKey ?? "displayName")
            let uid = user.uid
            let appleUserID = appleIDCredential.user

            // Persist the stable Apple ID so we can rehydrate without prompting every launch.
            self?.keychain.save(appleUserID, service: self?.keychainService ?? "", account: self?.keychainAccount ?? "")

            // Update UI properties on the main thread
            DispatchQueue.main.async {
                self?.displayName = resolvedName.isEmpty ? nil : resolvedName
                self?.userID = uid
                self?.isSignedIn = true
                self?.needsUsernamePrompt = false
            }

            self?.ensureUserDocument(uid: uid, displayName: resolvedName)

            print("✅ Signed in with Apple. UID: \(user.uid), Name: \(resolvedName)")
        }
    }
}

// MARK: - Apple Auth Handlers
extension AppleAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleAppleCredential(appleIDCredential)
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithError error: Error) {
        print("❌ Apple Sign-In failed: \(error.localizedDescription)")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ??
               UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .filter { $0.isKeyWindow }.first ?? UIWindow()
    }
}

/// Lightweight keychain helper to persist the Apple user identifier securely.
final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save(_ value: String, service: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(attributes as CFDictionary, nil)
    }
    
    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

extension AppleAuthManager {
    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        UserDefaults.standard.set(trimmed, forKey: displayNameKey)
        DispatchQueue.main.async {
            self.displayName = trimmed
        }

        let userRef = db.collection("users").document(uid)
        userRef.setData([
            "displayName": trimmed,
            "lastActiveAt": Timestamp(date: Date())
        ], merge: true)
    }

    private func ensureUserDocument(uid: String, displayName: String) {
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { [weak self] snapshot, _ in
            let now = Timestamp(date: Date())
            if snapshot?.exists == true {
                userRef.setData([
                    "displayName": displayName,
                    "lastActiveAt": now
                ], merge: true)
            } else {
                userRef.setData([
                    "displayName": displayName,
                    "createdAt": now,
                    "lastActiveAt": now
                ], merge: true)
            }
            self?.pendingUserID = nil
            self?.needsUsernamePrompt = false
        }
    }

    private func generateDefaultDisplayName() -> String {
        let suffix = Int.random(in: 1000...9999)
        return "Reader \(suffix)"
    }
}
