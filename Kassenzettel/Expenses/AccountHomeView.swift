//
//  AccountHomeView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import SwiftUI

struct AccountHomeView: View {
    @Environment(AuthModel.self) private var auth
    @State private var model = ExpensesModel(repository: SupabaseExpenseRepository())

    var body: some View {
        NavigationStack {
            ExpensesContentView(
                model: model,
                emptyHint: "Noch keine Ausgaben. Trage deine erste ein."
            )
            .navigationTitle("kassenzettel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AccountView()
                    } label: {
                        Label("Konto", systemImage: "person.crop.circle")
                    }
                }
            }
        }
        .task { await model.load() }
        .errorAlert(model)
    }
}
