//
//  YearCardsView.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import SwiftUI

struct YearCardsView: View {
    let expenses: [Expense]

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Grouping.yearTotals(expenses)) { item in
                NavigationLink(value: item.value) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(item.value))
                            .font(.title)
                            .bold()
                        Text(Money.format(cents: item.totalCents))
                            .foregroundStyle(.tint)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
