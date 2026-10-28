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
    
    func update(_ expense: Expense, store: String, amountCents: Int) async {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        let original = expenses[index]
        expenses[index].store = store
        expenses[index].amountCents = amountCents

        do {
            let saved = try await repository.update(id: expense.id, store: store, amountCents: amountCents)
            if let i = expenses.firstIndex(where: { $0.id == saved.id }) { expenses[i] = saved }
            errorMessage = nil
        } catch {
            logger.error("Update failed: \(error)")
            if let i = expenses.firstIndex(where: { $0.id == original.id }) { expenses[i] = original }
            errorMessage = "Die Änderung konnte nicht gespeichert werden."
        }
    }

    func delete(_ expense: Expense) async {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        let original = expenses.remove(at: index)

        do {
            try await repository.delete(id: expense.id)
            errorMessage = nil
        } catch {
            logger.error("Delete failed: \(error)")
            expenses.insert(original, at: min(index, expenses.count))
            errorMessage = "Die Ausgabe konnte nicht gelöscht werden."
        }
    }
}
