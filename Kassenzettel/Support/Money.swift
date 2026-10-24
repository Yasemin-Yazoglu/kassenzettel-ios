//
//  Money.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Foundation

enum Money {
    /// Euro → Cent, auf ganze Cent gerundet.
    static func cents(fromEuros euros: Decimal) -> Int {
        var value = euros * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    static func euros(fromCents cents: Int) -> Decimal {
        Decimal(cents) / 100
    }

    /// Cent → "19,99 €" (je nach Sprache des Geräts)
    static func format(cents: Int, locale: Locale = .current) -> String {
        euros(fromCents: cents)
            .formatted(.currency(code: "EUR").locale(locale))
    }
    
    /// "19,99" oder "19.99" (je nach Gerätesprache) → Decimal
    static func parse(_ text: String, locale: Locale = .current) -> Decimal? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        guard let number = formatter.number(from: text) as? NSDecimalNumber else { return nil }
        return number.decimalValue
    }
}
