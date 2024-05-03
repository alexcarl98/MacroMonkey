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
    var ratio: Double = 1.0
    var time: Date = Date.now
    
    static let `default` = Entry(food: 716429)
    static let `empty` = Entry(food: -1)
    
    // Convert Entry to dictionary
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(self),
           let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return dictionary
        }
        return [:]
    }

    // Initialize Entry from dictionary
    static func fromDictionary(_ dictionary: [String: Any]) -> Entry? {
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
           let entry = try? JSONDecoder().decode(Entry.self, from: data) {
            return entry
        }
        return nil
    }
}

struct Journal: Hashable, Codable, Identifiable {
    var id: String?
    var uid: String
    // want to change this so that it initializes journalDate as a string formatted "MM-dd-yyyy"
    var journalDate: String
    var entryLog = [Entry]()
    
    
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
