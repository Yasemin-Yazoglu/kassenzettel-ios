//
//  EditExpenseView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import SwiftUI

struct EditExpenseView: View {
    let expense: Expense
    let onSave: (_ store: String, _ amountCents: Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var store: String
    @State private var amountText: String

    init(expense: Expense, onSave: @escaping (_ store: String, _ amountCents: Int) -> Void) {
        self.expense = expense
        self.onSave = onSave
        _store = State(initialValue: expense.store)
        _amountText = State(initialValue: Money.editableString(cents: expense.amountCents))
    }

    private var newStore: String? { ExpenseInput.store(store) }
    private var newAmountCents: Int? { ExpenseInput.amountCents(from: amountText) }

    private var canSave: Bool {
        guard let newStore, let newAmountCents else { return false }
        return newStore != expense.store || newAmountCents != expense.amountCents
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Datum", value: "\(expense.day).\(expense.month).\(expense.year)")
                    TextField("Laden", text: $store)
                    TextField("Betrag in €", text: $amountText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Ausgabe bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private func save() {
        guard let newStore, let newAmountCents else { return }
        onSave(newStore, newAmountCents)
        dismiss()
    }
}
