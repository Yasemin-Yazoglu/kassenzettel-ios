//
//  InMemoryExpenseRepository.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

@MainActor
final class InMemoryExpenseRepository: ExpenseRepository {
    private var expenses: [Expense] = []

    func fetchAll() async throws -> [Expense] {
        expenses
    }

    func add(store: String, amountCents: Int, date: Date) async throws -> Expense {
        let calendar = Calendar.current
        let expense = Expense(
            id: UUID(),
            store: store,
            amountCents: amountCents,
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
        expenses.insert(expense, at: 0)
        return expense
    }
}
