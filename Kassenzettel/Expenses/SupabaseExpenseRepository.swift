//
//  SupabaseExpenseRepository.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation
import PostgREST
import Supabase

enum ExpenseError: Error {
    case invalidData
}

@MainActor
struct SupabaseExpenseRepository: ExpenseRepository {
    private let columns = "id, store, amount_cents, spend_at"

    func fetchAll() async throws -> [Expense] {
        // Kein Filter auf den Nutzer nötig: RLS liefert nur die eigenen Zeilen.
        let rows: [ExpenseRow] = try await supabase
            .from("expense")
            .select(columns)
            .order("spend_at", ascending: false)
            .order("created_at", ascending: false)
            .execute()
            .value
        return rows.compactMap { Expense(row: $0) }
    }

    func add(store: String, amountCents: Int, date: Date) async throws -> Expense {
        let newRow = NewExpenseRow(
            store: store,
            amountCents: amountCents,
            spendAt: DBDate.string(from: date)
        )
        let row: ExpenseRow = try await supabase
            .from("expense")
            .insert(newRow)
            .select(columns)
            .single()
            .execute()
            .value
        guard let expense = Expense(row: row) else { throw ExpenseError.invalidData }
        return expense
    }
}
