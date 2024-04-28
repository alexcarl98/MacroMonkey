//
//  Entry.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import Foundation

struct Entry: Hashable, Codable {
    var food: Food
    var ratio: Float
    var time: Date = Date.now
    var calories: Float { return food.cals * ratio }
    var proteins: Float { return food.protein * ratio }
    var carbohydrates: Float{ return food.carbs * ratio }
    var fats: Float { return food.fats * ratio }
}
