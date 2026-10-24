//
//  LoginView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isBusy = false

    var body: some View {
        VStack(spacing: 16) {
            Text("kassenzettel").font(.largeTitle).bold()

            TextField("E-Mail", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Passwort", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }

            Button {
                Task { await login() }
            } label: {
                Text("Anmelden").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isBusy || email.isEmpty || password.isEmpty)
        }
        .padding()
    }

    private func login() async {
        isBusy = true
        defer { isBusy = false }
        do {
            try await supabase.auth.signIn(email: email, password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
