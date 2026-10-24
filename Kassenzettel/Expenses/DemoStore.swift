//
//  DemoStore.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Foundation
import Observation

/// Hält die Demo-Ausgaben nur im Speicher (nichts wird gespeichert).
@Observable
@MainActor
final class DemoStore {
    private(set) var expenses: [Expense] = []

    func add(store: String, amountCents: Int, date: Date) {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        expenses.append(
            Expense(
                id: UUID(),
                store: store,
                amountCents: amountCents,
                year: parts.year!,
                month: parts.month!,
                day: parts.day!
            )
        )
    }
}
