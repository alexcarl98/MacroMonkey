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
}
