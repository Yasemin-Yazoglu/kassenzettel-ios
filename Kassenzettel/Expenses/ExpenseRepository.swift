//
//  ExpenseRepository.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

@MainActor
protocol ExpenseRepository {
    func fetchAll() async throws -> [Expense]
    func add(store: String, amountCents: Int, date: Date) async throws -> Expense
    func update(id: UUID, store: String, amountCents: Int) async throws -> Expense
    func delete(id: UUID) async throws
}
