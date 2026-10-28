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
}
