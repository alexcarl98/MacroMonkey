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
    var isFeatured: Bool
    var servSize: Float
    var servUnit: String
    var isFavorite: Bool
    var nutrients: Nutrient
    var calories: Float? { Float(nutrients.cals) }
    var img: String

    struct Nutrient: Hashable, Codable{
        var cals: Int
        var protein: Float
        var carbs: Float
        var fats: Float
    }
    
    var category: Category
    
    enum Category: String, CaseIterable, Codable{
        case fruits = "Fruits"
        case vegetables = "Vegetables"
        case seeds = "Seeds"
        case legumes = "Legumes"
        case grains = "Grains"
        case pasta = "Pasta"
        case dairy = "Dairy"
        case meats = "Meats"
        case nuts = "Nuts"
    }

    private var imageName: String
    var image: Image {
        Image(imageName)
    }
    
    var featureImage: Image? {
        isFeatured ? Image(imageName + "_feature") : nil
    }
}

