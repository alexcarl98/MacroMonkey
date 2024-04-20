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
    var foodLog = [Food]()
    
    func getTotalMacros() -> [Float] {
        var totals: [Float] = [0.0, 0.0, 0.0, 0.0]
        for food in foodLog {
            totals[0] += food.nutrients.cals
            totals[1] += food.nutrients.protein
            totals[2] += food.nutrients.carbs
            totals[3] += food.nutrients.fats
        } 
        return totals
    }
    
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < foodLog.count else {
            print("Index out of bounds")
            return
        }
        foodLog.remove(at: index)
    }
}
