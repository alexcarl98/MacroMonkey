//
//  Journal.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import Foundation

struct Journal: Hashable, Codable, Identifiable {
    var id: String
    var journalDate: Date
    var entryLog = [Entry]()
    func getTotalMacros() -> [Double] {
        var totals: [Double] = [0.0, 0.0, 0.0, 0.0]
        for entry in entryLog {
            totals[0] += entry.calories
            totals[1] += entry.proteins
            totals[2] += entry.carbohydrates
            totals[3] += entry.fats
        }
        return totals
    }
    
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < entryLog.count else {
            print("Index out of bounds")
            return
        }
        self.entryLog.remove(at: index)
    }
    
    mutating func addFoodEntry(_ food: Food){
        self.entryLog.append(Entry(food: food, ratio: 1.0))
    }
    
    static let `default` = Journal(
        id: "rxKNDDdD8HPi9pLUHtbOu3F178J3",
        journalDate: Date.now,
        entryLog: [Entry(food: Food.pasta, ratio: 1.2)]
    )
    
    static let `empty` = Journal(
        id: "0",
        journalDate: Date.now
    )
//    func getFirebaseEntries() -> [EntryLog] {
//        var entries = [EntryLog]()
//        for entry in entryLog {
//            entries.append(EntryLog(foodID: entry.food.id, ratio: Double(entry.ratio), time: entry.time))
//        }
//        
//        return entries
//    }
}
