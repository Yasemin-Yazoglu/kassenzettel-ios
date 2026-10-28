//
//  PeriodAggregation.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Foundation

struct PeriodRange {
    let start: Date   // erster Tag, 00:00
    let end: Date     // letzter Tag, 00:00
    let label: String
}

struct PeriodDataPoint: Identifiable {
    let id: String        // eindeutiger Schlüssel des Zeitraums
    let label: String     // Beschriftung der x-Achse
    let range: String     // ausführliche Beschreibung für die Auswahl
    var totalCents = 0
    var count = 0
}

enum PeriodAggregation {
    /// ISO-8601-Kalender: Wochen beginnen am Montag, Kalenderwochen wie in Deutschland.
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = .current
        return calendar
    }()

    // MARK: - Zeitraum

    static func periodRange(for period: Period, anchor: Date) -> PeriodRange {
        // Für gültige Datumswerte liefert der Kalender hier immer ein Ergebnis.
        let interval = calendar.dateInterval(of: period.calendarComponent, for: anchor)!
        let end = calendar.date(byAdding: .day, value: -1, to: interval.end)!

        let label: String
        switch period {
        case .week:
            label = "\(dayMonth(interval.start)) – \(dayMonth(end))"
        case .month:
            label = interval.start.formatted(.dateTime.month(.wide).year())
        case .year:
            label = String(calendar.component(.year, from: anchor))
        }
        return PeriodRange(start: interval.start, end: end, label: label)
    }

    static func shifted(_ anchor: Date, by direction: Int, period: Period) -> Date {
        calendar.date(byAdding: period.calendarComponent, value: direction, to: anchor) ?? anchor
    }

    /// Man kann nur bis zum aktuellen Zeitraum vorblättern.
    static func canGoNext(period: Period, anchor: Date, today: Date = Date()) -> Bool {
        let next = shifted(anchor, by: 1, period: period)
        return periodRange(for: period, anchor: next).start <= today
    }

    // MARK: - Summen

    static func buckets(_ expenses: [Expense], period: Period, anchor: Date) -> [PeriodDataPoint] {
        let range = periodRange(for: period, anchor: anchor)
        var points = emptyPoints(period: period, range: range)
        let indexByKey = Dictionary(
            points.enumerated().map { ($0.element.id, $0.offset) },
            uniquingKeysWith: { first, _ in first }
        )

        for expense in expenses {
            guard let date = date(of: expense),
                  date >= range.start, date <= range.end,
                  let index = indexByKey[key(of: date, period: period)] else { continue }
            points[index].totalCents += expense.amountCents
            points[index].count += 1
        }
        return points
    }

    // MARK: - Hilfsfunktionen

    private static func emptyPoints(period: Period, range: PeriodRange) -> [PeriodDataPoint] {
        switch period {
        case .week:
            return days(from: range.start, to: range.end).map { day in
                PeriodDataPoint(
                    id: key(of: day, period: .week),
                    label: day.formatted(.dateTime.weekday(.abbreviated)),
                    range: day.formatted(date: .complete, time: .omitted)
                )
            }

        case .month:
            var points: [PeriodDataPoint] = []
            var seen = Set<String>()
            for day in days(from: range.start, to: range.end) {
                let weekKey = key(of: day, period: .month)
                guard seen.insert(weekKey).inserted else { continue }
                let weekStart = calendar.dateInterval(of: .weekOfYear, for: day)!.start
                let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
                points.append(
                    PeriodDataPoint(
                        id: weekKey,
                        label: "KW \(calendar.component(.weekOfYear, from: day))",
                        range: "\(dayMonth(weekStart)) – \(dayMonth(weekEnd))"
                    )
                )
            }
            return points

        case .year:
            let year = calendar.component(.year, from: range.start)
            return (1...12).compactMap { month in
                guard let first = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
                    return nil
                }
                return PeriodDataPoint(
                    id: key(of: first, period: .year),
                    label: first.formatted(.dateTime.month(.abbreviated)),
                    range: first.formatted(.dateTime.month(.wide).year())
                )
            }
        }
    }

    /// Schlüssel des Bereichs, in den ein Tag fällt.
    private static func key(of date: Date, period: Period) -> String {
        switch period {
        case .week:
            return DBDate.string(from: date, calendar: calendar)
        case .month:
            let year = calendar.component(.yearForWeekOfYear, from: date)
            let week = calendar.component(.weekOfYear, from: date)
            return "\(year)-W\(week)"
        case .year:
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            return String(format: "%04d-%02d", year, month)
        }
    }

    private static func date(of expense: Expense) -> Date? {
        calendar.date(from: DateComponents(year: expense.year, month: expense.month, day: expense.day))
    }

    private static func days(from start: Date, to end: Date) -> [Date] {
        var result: [Date] = []
        var cursor = start
        while cursor <= end {
            result.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    private static func dayMonth(_ date: Date) -> String {
        date.formatted(.dateTime.day(.twoDigits).month(.twoDigits))
    }
}
