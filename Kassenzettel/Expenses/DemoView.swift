//
//  DemoView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct DemoView: View {
    @State private var demo = DemoStore()
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ExpenseFormView { name, cents, date in
                        demo.add(store: name, amountCents: cents, date: date)
                    }

                    if demo.expenses.isEmpty {
                        Text("Probier es aus: Trage eine Ausgabe ein. Zum Speichern brauchst du ein Konto.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        YearCardsView(expenses: demo.expenses)
                    }
                }
                .padding()
            }
            .navigationTitle("kassenzettel")
            .navigationDestination(for: Int.self) { year in
                MonthsView(
                    year: year,
                    expenses: demo.expenses.filter { $0.year == year }
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Anmelden") { showLogin = true }
                }
            }
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
        }
    }
}
