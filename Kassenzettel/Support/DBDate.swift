//
//  DBDate.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

enum DBDate {
    /// Datum → "YYYY-MM-DD" (der Kalendertag, den der Nutzer gewählt hat)
    static func string(from date: Date, calendar: Calendar = .current) -> String {
        String(
            format: "%04d-%02d-%02d",
            calendar.component(.year, from: date),
            calendar.component(.month, from: date),
            calendar.component(.day, from: date)
        )
    }
}
