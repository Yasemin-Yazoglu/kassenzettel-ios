//
//  ExpenseRow.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

/// Eine Zeile der Tabelle `expense`, wie Supabase sie liefert.
/// `nonisolated`, damit das Dekodieren nicht an den Main-Thread gebunden ist.
nonisolated struct ExpenseRow: Decodable {
    let id: UUID
    let store: String
    let amountCents: Int
    let spendAt: String          // "YYYY-MM-DD"

    enum CodingKeys: String, CodingKey {
        case id, store
        case amountCents = "amount_cents"
        case spendAt = "spend_at"
    }
}

/// Was die App beim Anlegen sendet. `id` und `user_id` setzt die Datenbank.
nonisolated struct NewExpenseRow: Encodable {
    let store: String
    let amountCents: Int
    let spendAt: String

    enum CodingKeys: String, CodingKey {
        case store
        case amountCents = "amount_cents"
        case spendAt = "spend_at"
    }
}

nonisolated struct UpdateExpenseRow: Encodable {
    let store: String
    let amountCents: Int

    enum CodingKeys: String, CodingKey {
        case store
        case amountCents = "amount_cents"
    }
}

extension Expense {
    /// Der einzige Ort, der eine DB-Zeile in das UI-Modell umwandelt.
    init?(row: ExpenseRow) {
        let parts = row.spendAt.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(
            id: row.id,
            store: row.store,
            amountCents: row.amountCents,
            year: parts[0],
            month: parts[1],
            day: parts[2]
        )
    }
}
