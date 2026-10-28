//
//  DemoView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct DemoView: View {
    @State private var model = ExpensesModel(repository: InMemoryExpenseRepository())
    @State private var authMode: AuthView.Mode?

    var body: some View {
        NavigationStack {
            ExpensesContentView(
                model: model,
                emptyHint: "Probier es aus: Trage eine Ausgabe ein. Zum Speichern brauchst du ein Konto."
            )
            .navigationTitle("kassenzettel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Anmelden") { authMode = .signIn }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    authMode = .signUp
                } label: {
                    Text("Konto erstellen").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .sheet(item: $authMode) { mode in
                AuthView(initialMode: mode)
            }
        }
    }
}
