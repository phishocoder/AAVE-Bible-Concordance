import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var creditCard: String = ""
    @State private var tier: String = "Pro"
    @State private var region: String = "US"
    @State private var didInit = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Login")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                // Flagged for masking via dashboard rule.
                .accessibilityIdentifier("pii.email")
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Credit Card Number", text: $creditCard)
                .keyboardType(.numberPad)
                // Flagged for masking via dashboard rule.
                .accessibilityIdentifier("pii.creditCard")
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button("Sign In") {
                let userId = email.isEmpty ? "guest-\(UUID().uuidString)" : email
                FSBridge.identify(userId: userId, accountTier: tier, region: region)
                FSBridge.event("login_submit", props: ["method": "email"])
            }
            .accessibilityIdentifier("login.submit")
        }
        .padding()
        .onAppear {
            guard !didInit else { return }
            didInit = true
            FSBridge.page("Login", props: ["form": "email"])
        }
    }
}

#Preview {
    LoginView()
}
