//
//  ExpenseFormView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct ExpenseFormView: View {
    var onSubmit: (_ store: String, _ amountCents: Int, _ date: Date) -> Void

    @State private var date = Date()
    @State private var store = ""
    @State private var amountText = ""

    private var amountCents: Int? {
        ExpenseInput.amountCents(from: amountText)
    }

    private var canSubmit: Bool {
        ExpenseInput.store(store) != nil && amountCents != nil
    }

    var body: some View {
        VStack(spacing: 12) {
            DatePicker("Datum", selection: $date, displayedComponents: .date)

            TextField("Laden", text: $store)
                .textFieldStyle(.roundedBorder)

            TextField("Betrag in €", text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            Button {
                submit()
            } label: {
                Text("Hinzufügen").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func submit() {
        guard let name = ExpenseInput.store(store), let cents = amountCents else { return }
        onSubmit(name, cents, date)
        store = ""
        amountText = ""
    }
}
