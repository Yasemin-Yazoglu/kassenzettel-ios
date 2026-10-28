//
//  KassenzettelTests.swift
//  KassenzettelTests
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Foundation
import Testing
@testable import Kassenzettel

@MainActor
struct MoneyTests {
    @Test func convertsEurosToCentsWithoutFloatDrift() {
        #expect(Money.cents(fromEuros: Decimal(string: "19.99")!) == 1999)
        #expect(Money.cents(fromEuros: Decimal(string: "0.29")!) == 29)
    }

    @Test func parsesGermanInput() {
        let parsed = Money.parse("19,99", locale: Locale(identifier: "de_DE"))
        #expect(parsed == Decimal(string: "19.99"))
    }
}

@MainActor
struct PeriodAggregationTests {
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        PeriodAggregation.calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func expense(_ year: Int, _ month: Int, _ day: Int, cents: Int) -> Expense {
        Expense(id: UUID(), store: "Test", amountCents: cents, year: year, month: month, day: day)
    }

    @Test func monthGroupsDaysIntoIsoWeeks() {
        let expenses = [
            expense(2026, 3, 1, cents: 1000),
            expense(2026, 3, 2, cents: 500),
            expense(2026, 3, 31, cents: 250),
            expense(2026, 2, 28, cents: 999),   // außerhalb des Monats
            expense(2026, 4, 1, cents: 999),    // außerhalb des Monats
        ]
        let points = PeriodAggregation.buckets(expenses, period: .month, anchor: date(2026, 3, 15))

        #expect(points.map(\.label) == ["KW 9", "KW 10", "KW 11", "KW 12", "KW 13", "KW 14"])
        #expect(points.map(\.totalCents) == [1000, 500, 0, 0, 0, 250])
        #expect(points.map(\.count) == [1, 1, 0, 0, 0, 1])
    }

    @Test func weekStartsOnMondayAndHasSevenDays() {
        let anchor = date(2026, 10, 28)   // ein Mittwoch
        let range = PeriodAggregation.periodRange(for: .week, anchor: anchor)
        let points = PeriodAggregation.buckets([expense(2026, 10, 28, cents: 700)], period: .week, anchor: anchor)

        #expect(range.start == date(2026, 10, 26))
        #expect(points.count == 7)
        #expect(points[2].totalCents == 700)
    }

    @Test func yearHasTwelveMonths() {
        let points = PeriodAggregation.buckets([expense(2026, 12, 24, cents: 300)], period: .year, anchor: date(2026, 6, 1))
        #expect(points.count == 12)
        #expect(points[11].totalCents == 300)
    }

    @Test func cannotNavigateIntoTheFuture() {
        let today = date(2026, 10, 28)
        #expect(!PeriodAggregation.canGoNext(period: .month, anchor: today, today: today))
        #expect(PeriodAggregation.canGoNext(period: .month, anchor: date(2026, 9, 15), today: today))
    }
}
