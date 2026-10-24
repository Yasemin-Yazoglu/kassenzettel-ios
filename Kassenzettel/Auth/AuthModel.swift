//
//  AuthModel.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Observation
import Supabase

@Observable
@MainActor
final class AuthModel {
    var session: Session?
    var isLoading = true

    func start() async {
        for await (_, session) in supabase.auth.authStateChanges {
            self.session = session
            self.isLoading = false
        }
    }

    func logout() async {
        try? await supabase.auth.signOut(scope: .local)
    }
}
