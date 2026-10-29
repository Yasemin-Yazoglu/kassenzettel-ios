import SwiftUI

struct ChangePasswordView: View {
    @Environment(AuthModel.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isBusy = false
    @State private var showSuccess = false

    private var canSave: Bool {
        !isBusy && !currentPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Aktuelles Passwort", text: $currentPassword)
                        .textContentType(.password)
                }

                Section {
                    SecureField("Neues Passwort", text: $newPassword)
                        .textContentType(.newPassword)
                    SecureField("Passwort bestätigen", text: $confirmPassword)
                        .textContentType(.newPassword)
                } footer: {
                    Text("Mindestens 8 Zeichen, ein Groß- und ein Kleinbuchstabe.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Passwort ändern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { Task { await save() } }
                        .disabled(!canSave)
                }
            }
            .alert("Passwort geändert", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Dein Passwort wurde erfolgreich geändert.")
            }
        }
        .interactiveDismissDisabled(isBusy)
    }

    private func save() async {
        errorMessage = nil
        if let problem = AuthValidation.changePasswordProblem(
            current: currentPassword, new: newPassword, confirm: confirmPassword
        ) {
            errorMessage = problem
            return
        }

        isBusy = true
        defer { isBusy = false }

        do {
            try await auth.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            showSuccess = true
        } catch {
            errorMessage = AuthErrorMessage.text(for: error)
        }
    }
}
