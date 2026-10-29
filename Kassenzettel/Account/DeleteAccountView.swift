import SwiftUI
import os

private let logger = Logger(subsystem: "Kassenzettel", category: "account")

struct DeleteAccountView: View {
    @Environment(AuthModel.self) private var auth
    @Environment(\.dismiss) private var dismiss

    private let confirmWord = "löschen"

    @State private var confirmText = ""
    @State private var errorMessage: String?
    @State private var isBusy = false

    private var isConfirmed: Bool {
        confirmText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == confirmWord
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Diese Aktion kann nicht rückgängig gemacht werden. Alle deine Daten, einschließlich deiner Ausgaben, werden dauerhaft gelöscht.")
                }

                Section {
                    TextField("„\(confirmWord)“ eingeben", text: $confirmText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } footer: {
                    Text("Gib „\(confirmWord)“ ein, um zu bestätigen.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await delete() }
                    } label: {
                        Group {
                            if isBusy { ProgressView() } else { Text("Konto endgültig löschen") }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isConfirmed || isBusy)
                }
            }
            .navigationTitle("Konto löschen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .disabled(isBusy)
                }
            }
        }
        .interactiveDismissDisabled(isBusy)
    }

    private func delete() async {
        isBusy = true
        errorMessage = nil
        do {
            try await auth.deleteAccount()
            // Bei Erfolg wechselt RootView in die Demo, dieses Sheet verschwindet dabei.
        } catch {
            logger.error("Delete account failed: \(error)")
            errorMessage = "Konto konnte nicht gelöscht werden. Bitte versuche es erneut."
            isBusy = false
        }
    }
}
