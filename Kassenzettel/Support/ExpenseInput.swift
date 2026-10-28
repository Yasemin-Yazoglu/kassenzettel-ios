//
//  ExpenseInput.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//


import Foundation

enum ExpenseInput {
    private static let maxEuros = Decimal(Int(Int32.max)) / 100

    /// Name ohne Leerzeichen am Rand, oder nil, wenn er leer ist.
    static func store(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Eingegebener Betrag in Cent, oder nil, wenn er ungültig oder zu groß ist.
    static func amountCents(from text: String) -> Int? {
        guard let euros = Money.parse(text), euros > 0, euros <= maxEuros else { return nil }
        return Money.cents(fromEuros: euros)
    }
}
