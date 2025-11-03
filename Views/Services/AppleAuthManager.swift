import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import CryptoKit

class AppleAuthManager: NSObject, ObservableObject {
    static let shared = AppleAuthManager()

    @Published var isSignedIn = false
    @Published var displayName: String?
    @Published var userID: String?
    @Published var needsUsernamePrompt = false
    @Published var pendingUserID: String?

    private let db = Firestore.firestore()
    private var currentNonce: String?
    
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

    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - Apple Auth Handlers
extension AppleAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func authorizationController(controller: ASAuthorizationController,
                                  didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

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
                let displayName = appleIDCredential.fullName?.givenName ?? "User"
                let uid = user.uid
                
                // Update UI properties on the main thread
                DispatchQueue.main.async {
                    self?.displayName = displayName
                    self?.userID = uid
                    self?.isSignedIn = true
                }

                let userRef = self?.db.collection("users").document(user.uid)

                userRef?.setData([
                    "name": displayName,
                    "email": user.email ?? "",
                    "createdAt": Timestamp(date: Date())
                ], merge: true)

                // Check if a username already exists, if not trigger prompt
                userRef?.getDocument { snapshot, error in
                    if let data = snapshot?.data(), data["username"] == nil {
                        DispatchQueue.main.async {
                            self?.pendingUserID = uid
                            self?.needsUsernamePrompt = true
                        }
                    }
                }

                print("✅ Signed in with Apple. UID: \(user.uid), Name: \(displayName)")
            }
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
