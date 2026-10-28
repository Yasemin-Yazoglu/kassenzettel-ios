//
//  AnalyticsTypes.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

enum Period: String, CaseIterable, Identifiable {
    case week, month, year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week: "Woche"
        case .month: "Monat"
        case .year: "Jahr"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}

enum Metric: String, CaseIterable, Identifiable {
    case total, count

    var id: String { rawValue }

    var pickerTitle: String {
        switch self {
        case .total: "Betrag"
        case .count: "Anzahl"
        }
    }

    var chartTitle: String {
        switch self {
        case .total: "Ausgabenverlauf"
        case .count: "Einkaufshäufigkeit"
        }
    }

    func value(of point: PeriodDataPoint) -> Int {
        switch self {
        case .total: point.totalCents
        case .count: point.count
        }
    }

    func format(_ value: Int) -> String {
        switch self {
        case .total: Money.format(cents: value)
        case .count: String(value)
        }
    }
}
