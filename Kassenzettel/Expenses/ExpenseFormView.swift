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
        guard let euros = Money.parse(amountText), euros > 0 else { return nil }
        return Money.cents(fromEuros: euros)
    }

    private var canSubmit: Bool {
        !store.trimmingCharacters(in: .whitespaces).isEmpty && amountCents != nil
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
        guard let cents = amountCents else { return }
        onSubmit(store.trimmingCharacters(in: .whitespaces), cents, date)
        store = ""
        amountText = ""
    }
}
