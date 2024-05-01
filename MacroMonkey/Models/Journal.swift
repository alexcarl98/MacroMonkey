//
//  Journal.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import Foundation
import FirebaseFirestore

struct Entry: Hashable, Codable {
    var food: Int
    var ratio: Double
    var time: Date = Date.now
    
    enum CodingKeys: String,CodingKey{
        case food = "foodID"
        case ratio
        case time
    }
}
    
struct Journal: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var journalDate: Date = Date.now
    var entryLog = [Entry]()
    
    
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < entryLog.count else {
            print("Index out of bounds")
            return
        }
        self.entryLog.remove(at: index)
    }
    
    mutating func addFoodEntry(_ food: Food){
        self.entryLog.append(Entry(food: food.fid, ratio: 1.0))
    }
    
    static let `default` = Journal(
        uid: "rxKNDDdD8HPi9pLUHtbOu3F178J3",
        journalDate: Date.now,
        entryLog: [Entry(food: 716429, ratio: 1.2)]
    )
    
    func getEntry(at index: Int) -> Entry{
        return entryLog[index]
    }
//
    static let `empty` = Journal(
        uid: ""
    )
    
    enum CodingKeys: String,CodingKey {
        case id
        case uid
        case journalDate = "date"
        case entryLog = "entries"
    }
}
