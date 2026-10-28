//
//  ExpensesContentView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import SwiftUI

struct ExpensesContentView: View {
    let model: ExpensesModel
    let emptyHint: String

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ExpenseFormView { name, cents, date in
                    Task { await model.add(store: name, amountCents: cents, date: date) }
                }

                if model.isLoading && model.expenses.isEmpty {
                    ProgressView()
                } else if model.expenses.isEmpty {
                    Text(emptyHint)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    YearCardsView(expenses: model.expenses)
                }
            }
            .padding()
        }
        .refreshable { await model.load() }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    AnalyticsView(model: model)
                } label: {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
            }
        }
        .navigationDestination(for: Int.self) { year in
            MonthsView(year: year, model: model)
        }
    }
}

extension View {
    /// Zeigt `errorMessage` des Models als Warnung an.
    func errorAlert(_ model: ExpensesModel) -> some View {
        alert(
            "Fehler",
            isPresented: Binding(
                get: { model.errorMessage != nil },
                set: { if !$0 { model.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
