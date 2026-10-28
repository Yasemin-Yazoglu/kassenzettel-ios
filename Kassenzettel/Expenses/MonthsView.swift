//
//  MonthsView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct MonthsView: View {
    let year: Int
    let model: ExpensesModel

    @State private var editing: Expense?
    @State private var deleting: Expense?

    private var expenses: [Expense] {
        model.expenses.filter { $0.year == year }
    }

    var body: some View {
        List {
            ForEach(Grouping.monthTotals(expenses)) { month in
                DisclosureGroup {
                    ForEach(entries(in: month.value)) { expense in
                        row(for: expense)
                    }
                } label: {
                    HStack {
                        Text(monthName(month.value))
                        Spacer()
                        Text(Money.format(cents: month.totalCents))
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
        .overlay {
            if expenses.isEmpty {
                ContentUnavailableView(
                    "Keine Ausgaben",
                    systemImage: "tray",
                    description: Text("In diesem Jahr gibt es keine Ausgaben.")
                )
            }
        }
        .navigationTitle(String(year))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editing) { expense in
            EditExpenseView(expense: expense) { store, cents in
                Task { await model.update(expense, store: store, amountCents: cents) }
            }
        }
        .confirmationDialog(
            "Ausgabe löschen?",
            isPresented: Binding(
                get: { deleting != nil },
                set: { if !$0 { deleting = nil } }
            ),
            titleVisibility: .visible,
            presenting: deleting
        ) { expense in
            Button("Löschen", role: .destructive) {
                Task { await model.delete(expense) }
            }
        } message: { expense in
            Text(deleteMessage(for: expense))
        }
    }

    private func row(for expense: Expense) -> some View {
        Button {
            editing = expense
        } label: {
            HStack {
                Text("\(expense.day).")
                    .foregroundStyle(.secondary)
                    .frame(width: 32, alignment: .leading)
                Text(expense.store)
                    .lineLimit(1)
                Spacer()
                Text(Money.format(cents: expense.amountCents))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleting = expense
            } label: {
                Label("Löschen", systemImage: "trash")
            }
            Button {
                editing = expense
            } label: {
                Label("Bearbeiten", systemImage: "pencil")
            }
            .tint(.indigo)
        }
    }

    private func entries(in month: Int) -> [Expense] {
        expenses
            .filter { $0.month == month }
            .sorted { $0.day > $1.day }
    }

    private func monthName(_ month: Int) -> String {
        Calendar.current.monthSymbols[month - 1]
    }

    private func deleteMessage(for expense: Expense) -> String {
        let date = "\(expense.day).\(expense.month).\(String(expense.year))"
        return "Möchtest du die Ausgabe vom \(date) bei \(expense.store) in Höhe von \(Money.format(cents: expense.amountCents)) wirklich löschen?"
    }
}
