//
//  Grouping.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Foundation

/// Summe eines Zeitraums (ein Jahr oder ein Monat), in Cent.
struct PeriodTotal: Identifiable {
    let value: Int        // Jahr oder Monat
    let totalCents: Int
    var id: Int { value }
}

enum Grouping {
    static func yearTotals(_ expenses: [Expense]) -> [PeriodTotal] {
        totals(expenses, by: \.year)
    }

    static func monthTotals(_ expenses: [Expense]) -> [PeriodTotal] {
        totals(expenses, by: \.month)
    }

    /// Neueste zuerst (absteigend sortiert)
    private static func totals(_ expenses: [Expense], by key: KeyPath<Expense, Int>) -> [PeriodTotal] {
        Dictionary(grouping: expenses, by: { $0[keyPath: key] })
            .map { period, items in
                PeriodTotal(value: period, totalCents: items.reduce(0) { $0 + $1.amountCents })
            }
            .sorted { $0.value > $1.value }
    }
}
