import SwiftUI

struct AuthView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Anmelden"
        case signUp = "Registrieren"
        var id: String { rawValue }
    }

    @Environment(AuthModel.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var mode: Mode
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isBusy = false
    @State private var confirmationEmail: String?

    init(initialMode: Mode = .signIn) {
        _mode = State(initialValue: initialMode)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let confirmationEmail {
                    confirmation(email: confirmationEmail)
                } else {
                    form
                }
            }
            .navigationTitle(mode.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }

    private var form: some View {
        VStack(spacing: 16) {
            Picker("", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)

            TextField("E-Mail", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Passwort", text: $password)
                .textContentType(mode == .signIn ? .password : .newPassword)
                .textFieldStyle(.roundedBorder)

            if mode == .signUp {
                Text("Mindestens 8 Zeichen, mit Groß- und Kleinbuchstaben.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await submit() }
            } label: {
                Group {
                    if isBusy { ProgressView() } else { Text(mode.rawValue) }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isBusy || email.isEmpty || password.isEmpty)

            Spacer()
        }
        .padding()
        .onChange(of: mode) { errorMessage = nil }
    }

    private func confirmation(email: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.badge")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Bestätige deine E-Mail")
                .font(.title2)
                .bold()
            Text("Wir haben einen Link an \(email) geschickt. Öffne ihn auf diesem Gerät, dann bist du direkt eingeloggt.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Schließen") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding()
    }

    private func submit() async {
        errorMessage = nil
        let normalizedEmail = AuthValidation.normalizedEmail(email)

        guard AuthValidation.isValidEmail(normalizedEmail) else {
            errorMessage = "Bitte gib eine gültige E-Mail-Adresse ein."
            return
        }
        if mode == .signUp, let problem = AuthValidation.passwordProblem(password) {
            errorMessage = problem
            return
        }

        isBusy = true
        defer { isBusy = false }

        do {
            switch mode {
            case .signIn:
                try await auth.signIn(email: normalizedEmail, password: password)
            case .signUp:
                let result = try await auth.signUp(email: normalizedEmail, password: password)
                if result == .needsEmailConfirmation {
                    confirmationEmail = normalizedEmail
                }
            }
            // Bei Erfolg wechselt RootView von selbst, das Sheet verschwindet dabei.
        } catch {
            errorMessage = AuthErrorMessage.text(for: error)
        }
    }
}
