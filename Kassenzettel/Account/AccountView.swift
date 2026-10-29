import Auth
import SwiftUI

struct AccountView: View {
    @Environment(AuthModel.self) private var auth
    @State private var showChangePassword = false
    @State private var showDeleteAccount = false

    var body: some View {
        List {
            if let user = auth.session?.user {
                Section {
                    header(for: user)
                } footer: {
                    Text("Mitglied seit \(user.createdAt.formatted(.dateTime.month(.wide).year()))")
                }

                if hasPasswordLogin(user) {
                    Section("Einstellungen") {
                        Button("Passwort ändern") { showChangePassword = true }
                    }
                }

                Section {
                    Button("Abmelden") { Task { await auth.logout() } }
                }

                Section {
                    Button("Konto löschen", role: .destructive) { showDeleteAccount = true }
                }
            }
        }
        .navigationTitle("Konto")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showChangePassword) { ChangePasswordView() }
        .sheet(isPresented: $showDeleteAccount) { DeleteAccountView() }
    }

    private func header(for user: User) -> some View {
        let name = user.userMetadata["full_name"]?.stringValue
        let email = user.email ?? ""
        let avatar = user.userMetadata["avatar_url"]?.stringValue.flatMap { URL(string: $0) }

        return HStack(spacing: 16) {
            AvatarView(url: avatar, fallbackText: name ?? email)
            VStack(alignment: .leading, spacing: 2) {
                Text(name ?? email)
                    .font(.headline)
                    .lineLimit(1)
                if name != nil {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    /// Wie in der Web-App: Passwort ändern gibt es nur bei E-Mail-Login, nicht bei reinem Google-Login.
    private func hasPasswordLogin(_ user: User) -> Bool {
        user.identities?.contains { $0.provider == "email" } ?? false
    }
}
