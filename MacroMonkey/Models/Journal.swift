//
//  Journal.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import Foundation
import FirebaseFirestore

struct Entry: Hashable, Codable {
//    @DocumentID var id: String?
    var food: Int
    var ratio: Double = 1.0
    var time: Date = Date.now
    
    static let `default` = Entry(food: 716429)
}

struct Journal: Hashable, Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    // want to change this so that it initializes journalDate as a string formatted "MM-dd-yyyy"
    var journalDate: String
    var entryLog = [Entry]()
//    var entries = [String]()
    
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < entryLog.count else {
            print("Index out of bounds")
            return
        }
        self.entryLog.remove(at: index)
    }
    
    mutating func addFoodEntry(_ food: Food){
        self.entryLog.append(Entry(food: food.id, ratio: 1.0))
    }
    
    func getEntry(at index: Int) -> Entry {
        return self.entryLog[index]
    }
    
    func getEntriesInBulk() -> [Int] {
        return entryLog.map { $0.food }
    }
    
    static let `default` = Journal(
        uid: "rxKNDDdD8HPi9pLUHtbOu3F178J3",
        journalDate: "Date.now",
        entryLog: [Entry.default]
    )

    static let `empty` = Journal( uid: "" , journalDate: "")
    
    enum CodingKeys: String,CodingKey {
        case id
        case uid
        case journalDate
        case entryLog
    }
}
