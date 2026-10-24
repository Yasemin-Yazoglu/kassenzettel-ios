//
//  Expense.swift
//  Kassenzettel
//
//  Created by Yasemin Yazoglu on 24.10.26.
//

import Foundation

struct Expense: Identifiable, Equatable {
    let id: UUID
    var store: String
    var amountCents: Int
    var year: Int
    var month: Int
    var day: Int
}
