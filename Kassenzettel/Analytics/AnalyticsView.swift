//
//  AnalyticsView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 28.10.26.
//

import Charts
import SwiftUI

struct AnalyticsView: View {
    let model: ExpensesModel

    @State private var period: Period = .month
    @State private var metric: Metric = .total
    @State private var anchor = Date()
    @State private var selectedLabel: String?

    var body: some View {
        let data = PeriodAggregation.buckets(model.expenses, period: period, anchor: anchor)
        let total = data.reduce(0) { $0 + metric.value(of: $1) }
        let selected = data.first { $0.label == selectedLabel }
        let rangeLabel = PeriodAggregation.periodRange(for: period, anchor: anchor).label
        let canGoNext = PeriodAggregation.canGoNext(period: period, anchor: anchor)

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Anzeige", selection: $metric) {
                    ForEach(Metric.allCases) { Text($0.pickerTitle).tag($0) }
                }
                .pickerStyle(.segmented)

                Picker("Zeitraum", selection: $period) {
                    ForEach(Period.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)

                HStack {
                    Button { shift(-1) } label: { Image(systemName: "chevron.left") }
                        .accessibilityLabel("Vorheriger Zeitraum")

                    Text(rangeLabel)
                        .font(.subheadline)
                        .bold()
                        .frame(minWidth: 120)

                    Button { shift(1) } label: { Image(systemName: "chevron.right") }
                        .disabled(!canGoNext)
                        .accessibilityLabel("Nächster Zeitraum")

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(selected?.range ?? metric.chartTitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(metric.format(selected.map { metric.value(of: $0) } ?? total))
                        .font(.title)
                        .bold()
                }

                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Zeitraum", point.label),
                            y: .value(metric.chartTitle, metric.value(of: point))
                        )
                        .interpolationMethod(.monotone)

                        PointMark(
                            x: .value("Zeitraum", point.label),
                            y: .value(metric.chartTitle, metric.value(of: point))
                        )
                    }

                    if let selectedLabel {
                        RuleMark(x: .value("Auswahl", selectedLabel))
                            .foregroundStyle(.secondary.opacity(0.4))
                    }
                }
                .chartXSelection(value: $selectedLabel)
                .chartYScale(domain: .automatic(includesZero: true))
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Int.self) {
                                Text(metric.format(amount))
                            }
                        }
                    }
                }
                .frame(height: 260)
                .overlay {
                    if data.allSatisfy({ $0.count == 0 }) {
                        Text("Keine Ausgaben in diesem Zeitraum")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: period) {
            anchor = Date()
            selectedLabel = nil
        }
        .onChange(of: anchor) { selectedLabel = nil }
    }

    private func shift(_ direction: Int) {
        anchor = PeriodAggregation.shifted(anchor, by: direction, period: period)
    }
}
