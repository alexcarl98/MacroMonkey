//
//  FBEntry.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/29/24.
//

import Foundation

struct FBEntry: Hashable, Codable, Identifiable {
    var jid: String
    var foodID: Int
    var ratio: Float
    var time: Date = Date.now
    var id: String = ""
    var calories: Float { return (foodCache[self.foodID]?.cals ?? 0.0) * self.ratio }
    var proteins: Float { return (foodCache[self.foodID]?.protein ?? 0.0) * self.ratio }
    var carbohydrates: Float{ return (foodCache[self.foodID]?.carbs ?? 0.0) * self.ratio }
    var fats: Float { return (foodCache[self.foodID]?.fats ?? 0.0) * self.ratio }
    
    static let `default` = FBEntry(jid: "SdOuQS0iGMpapHaHGfWw", foodID: 716429, ratio: 1.2, time: Date.now)
    static let `empty` = FBEntry(jid: "0", foodID: 0, ratio: 0.0)
}
