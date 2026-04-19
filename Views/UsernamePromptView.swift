import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UsernamePromptView: View {
    @Environment(\.dismiss) var dismiss
    @State private var username: String
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var userID: String?
    var onSaved: (() -> Void)?
    
    init(userID: String? = nil, onSaved: (() -> Void)? = nil) {
        self.userID = userID
        self.onSaved = onSaved
        let savedName = UserDefaults.standard.string(forKey: "displayName")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        _username = State(initialValue: QuizScoreLogger.isPlaceholderDisplayName(savedName) ? "" : savedName)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Your Name")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This is what shows on the leaderboard after you finish the quiz. You can update it later in Profile.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Enter your first name", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: saveUsername) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("Username")
        }
    }

    func saveUsername() {
        // Get user ID either from parameter or current user
        let uid = userID ?? Auth.auth().currentUser?.uid
        
        guard let uid = uid else {
            errorMessage = "Not signed in."
            return
        }

        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 2 else {
            errorMessage = "Name must be at least 2 characters."
            return
        }

        isSaving = true

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.setData([
            "displayName": trimmed,
            "updatedAt": Timestamp(date: Date())
        ], merge: true) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    errorMessage = "Error saving: \(error.localizedDescription)"
                } else {
                    UserDefaults.standard.set(trimmed, forKey: "displayName")
                    print("✅ Display name saved: \(trimmed)")
                    onSaved?()
                    dismiss()
                }
            }
        }
    }
}
