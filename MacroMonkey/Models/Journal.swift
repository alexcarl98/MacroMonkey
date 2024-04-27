//
//  Journal.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import Foundation


struct Journal: Hashable, Codable, Identifiable {
    var id: Int
    var journalDate: Date
    var entryLog = [Entry]()
    func getTotalMacros() -> [Float] {
        var totals: [Float] = [0.0, 0.0, 0.0, 0.0]
        for entry in entryLog {
            totals[0] += entry.food.nutrients.cals * entry.ratio
            totals[1] += entry.food.nutrients.protein * entry.ratio
            totals[2] += entry.food.nutrients.carbs * entry.ratio
            totals[3] += entry.food.nutrients.fats * entry.ratio
        }
        return totals
    }
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < entryLog.count else {
            print("Index out of bounds")
            return
        }
        entryLog.remove(at: index)
    }
    static let `default` = Journal(
        id: 1001,
        journalDate: Date.now,
        entryLog: [Entry(food: Food.pasta, ratio: 1.2)]
    )
}
