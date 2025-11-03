import SwiftUI

struct SettingsView: View {
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var creditCard: String = ""
    @State private var address: String = ""
    @State private var didInit = false

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Full Name", text: $fullName)
                    .textContentType(.name)
                TextField("Email Address", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Credit Card Number", text: $creditCard)
                    .textContentType(.creditCardNumber)
                    .keyboardType(.numberPad)
                TextField("Home Address", text: $address)
                    .textContentType(.fullStreetAddress)
            }

            Section {
                Button("Save Changes") {
                    print("Settings saved for \(fullName)")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .accessibilityIdentifier("mask.screen.settings")
        .navigationTitle("Account Settings")
        .onAppear {
            guard !didInit else { return }
            didInit = true
            FSBridge.page("Settings", props: ["source": "tab"])
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
