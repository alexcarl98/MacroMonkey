//
//  Entry.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import Foundation

struct Entry: Hashable, Codable {
    var food: Food
    var ratio: Double
    var time: Date = Date.now
    var calories: Double { return food.cals * ratio }
    var proteins: Double { return food.protein * ratio }
    var carbohydrates: Double{ return food.carbs * ratio }
    var fats: Double { return food.fats * ratio }
}
