//
//  ExpensesModel.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation
import Observation
import os

private let logger = Logger(subsystem: "Kassenzettel", category: "expenses")

@Observable
@MainActor
final class ExpensesModel {
    private(set) var expenses: [Expense] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let repository: any ExpenseRepository

    init(repository: any ExpenseRepository) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            expenses = try await repository.fetchAll()
            errorMessage = nil
        } catch {
            logger.error("Load failed: \(error)")
            errorMessage = "Die Ausgaben konnten nicht geladen werden."
        }
    }

    func add(store: String, amountCents: Int, date: Date) async {
        do {
            let expense = try await repository.add(store: store, amountCents: amountCents, date: date)
            expenses.insert(expense, at: 0)
            errorMessage = nil
        } catch {
            logger.error("Add failed: \(error)")
            errorMessage = "Die Ausgabe konnte nicht gespeichert werden."
        }
    }
}
