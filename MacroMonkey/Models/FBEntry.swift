//
//  FBEntry.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/29/24.
//

import Foundation

struct FBEntry: Hashable, Codable, Identifiable {
    var id: String = ""
    var jid: String
    var foodID: Int
    var ratio: Float
    var date: Date = Date.now
}
