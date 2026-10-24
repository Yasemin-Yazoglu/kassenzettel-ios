//
//  RootView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI
import Supabase

struct RootView: View {
    @Environment(AuthModel.self) private var auth

    var body: some View {
        if auth.isLoading {
            ProgressView()
        } else if let session = auth.session {
            VStack(spacing: 16) {
                Text("Eingeloggt als \(session.user.email ?? "")")
                Button("Abmelden") { Task { await auth.logout() } }
            }
        } else {
            DemoView()
        }
    }
}
