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
    var name: String
    var servSize: Float
    var servUnit: String
    var isFavorite: Bool
    var nutrients: Nutrient
    var img: String
    
    struct Nutrient: Hashable, Codable{
        var cals: Float
        var protein: Float
        var carbs: Float
        var fats: Float
        static let `pasta` = Nutrient(cals: 543.36, protein: 16.84, carbs: 83.7, fats: 16.2)
    }
    
    static let `pasta` = Food(
        id: 716429,
        name: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs",
        servSize: 259.0,
        servUnit: "g",
        isFavorite: false,
        nutrients: Nutrient.pasta,
        img: "https://img.spoonacular.com/recipes/716429-556x370.jpg"
    )
}

