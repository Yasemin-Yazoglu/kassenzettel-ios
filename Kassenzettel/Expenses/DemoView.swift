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
                        VStack(spacing: 8) {
                            ForEach(demo.expenses.reversed()) { expense in
                                HStack {
                                    Text(expense.store)
                                    Spacer()
                                    Text(Money.format(cents: expense.amountCents))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("kassenzettel")
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
