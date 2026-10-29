//
//  AuthModel.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Auth
import Foundation
import Observation
import Supabase

@Observable
@MainActor
final class AuthModel {
    var session: Session?
    var isLoading = true

    enum SignUpResult {
        case signedIn
        case needsEmailConfirmation
    }

    func start() async {
        for await (_, session) in supabase.auth.authStateChanges {
            self.session = session
            self.isLoading = false
        }
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> SignUpResult {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            redirectTo: AppConfig.authCallbackURL
        )
        return response.session == nil ? .needsEmailConfirmation : .signedIn
    }

    /// Wird aufgerufen, wenn der Link aus der Bestätigungs-E-Mail die App öffnet.
    func handle(url: URL) async {
        _ = try? await supabase.auth.session(from: url)
    }

    func logout() async {
        try? await supabase.auth.signOut(scope: .local)
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let email = session?.user.email else { throw AccountError.notSignedIn }

        // Erst das aktuelle Passwort beweisen lassen, dann ersetzen.
        // Das funktioniert unabhängig davon, ob das Projekt "current password" verlangt.
        do {
            try await supabase.auth.signIn(email: email, password: currentPassword)
        } catch let error as AuthError where error.errorCode.rawValue == "invalid_credentials" {
            throw AccountError.wrongCurrentPassword
        }
        try await supabase.auth.update(user: UserAttributes(password: newPassword))
    }

    func deleteAccount() async throws {
        try await supabase.functions.invoke(
            "delete-account",
            options: FunctionInvokeOptions(method: .post)
        )
        // Die Sitzung ist serverseitig schon weg; lokal aufräumen.
        try? await supabase.auth.signOut(scope: .local)
    }
    
    func signInWithGoogle() async throws {
        _ = try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: AppConfig.authCallbackURL,
            queryParams: [(name: "prompt", value: "select_account")]
        )
    }
}
