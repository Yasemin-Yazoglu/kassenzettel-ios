//
//  MonthsView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct MonthsView: View {
    let year: Int
    let expenses: [Expense]    // nur die Ausgaben dieses Jahres

    var body: some View {
        List {
            ForEach(Grouping.monthTotals(expenses)) { month in
                DisclosureGroup {
                    ForEach(entries(in: month.value)) { expense in
                        HStack {
                            Text("\(expense.day).")
                                .foregroundStyle(.secondary)
                                .frame(width: 32, alignment: .leading)
                            Text(expense.store)
                                .lineLimit(1)
                            Spacer()
                            Text(Money.format(cents: expense.amountCents))
                        }
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
        .navigationTitle(String(year))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func entries(in month: Int) -> [Expense] {
        expenses
            .filter { $0.month == month }
            .sorted { $0.day > $1.day }
    }

    /// "Januar", "Februar", ... (richtet sich nach der Gerätesprache)
    private func monthName(_ month: Int) -> String {
        Calendar.current.monthSymbols[month - 1]
    }
}
