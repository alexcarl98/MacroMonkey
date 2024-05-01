//
//  Food.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import Foundation
import SwiftUI
import CoreLocation

struct Food: Hashable, Codable, Identifiable {
    var id: Int
//    var fid: Int
    var name: String
    var servSize: Double
    var servUnit: String
    var cals: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var img: String
    
    
    func formatted_macros() -> [Double] { return [cals, fats, carbs, protein] }
    
    static let `pasta` = Food (
        id: 716429,
//        name: "Pasta",
        name: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs",
        servSize: 259.0,
        servUnit: "g",
        cals: 543.36, 
        protein: 16.84,
        carbs: 83.7,
        fats: 16.2,
        img: "https://img.spoonacular.com/recipes/716429-556x370.jpg"
    )
    
    static let `empty` = Food (
        id: 0,
        name: "Nothing",
        servSize: 0.0,
        servUnit: "g",
        cals: 0.0,
        protein: 0.0,
        carbs: 0.0,
        fats: 0.0,
        img: "https://upload.wikimedia.org/wikipedia/commons/1/18/Color-white.JPG"
    )
}
