//
//  Journal.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import Foundation
import FirebaseFirestore

struct Entry: Hashable, Codable {
//    var food: Food
    var food: Int
    var ratio: Double
    var time: Date = Date.now
    
    enum CodingKeys: String,CodingKeys{
        case food = "foodID"
        case ratio
        case time
    }
}
    
struct Journal: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var journalDate: Date
//    var entryLog = [Entry]()
    var entries: [Entry]?
    
//    var entryLog: [Entry] {
//        return entries ?? [Entry]()
//    }
    
    func getTotalMacros(foodCache: [Int:Food]) -> [Double] {
        var totals: [Double] = [0.0, 0.0, 0.0, 0.0]
        if let entryLog = entries{
            for entry in entryLog {
                totals[0] += (foodCache[entry.food]?.cals ?? 0) * entry.ratio
                totals[1] += (foodCache[entry.food]?.protein ?? 0) * entry.ratio
                totals[2] += (foodCache[entry.food]?.carbs ?? 0) * entry.ratio
                totals[3] += (foodCache[entry.food]?.fats ?? 0) * entry.ratio
            }
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
    
//    static let `default` = Journal(
//        uid: "rxKNDDdD8HPi9pLUHtbOu3F178J3",
//        journalDate: Date.now,
//        entryLog: [Entry(food: 716429, ratio: 1.2)]
//    )
//    
//    static let `empty` = Journal(
//        id: "0",
//        uid: "",
//        journalDate: Date.now
//    )
    
    enum CodingKeys: String,CodingKeys {
        case id
        case uid
        case journalDate = "date"
        case entryLog = "entries"
    }
}
