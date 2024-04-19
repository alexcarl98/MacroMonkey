//
//  File.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import Foundation



struct NutrientAPI: Hashable, Codable{
    var name: String
    var amount: Float
    var unit: String
    var percentOFDailyNeeds: Float
}

struct WeightAPI: Hashable, Codable{
    var amount: Float
    var unit: String
}

struct NutritionAPI: Hashable, Codable {
    var nutrients: [NutrientAPI]
    var weightPerServing: WeightAPI
}

struct FoodAPI: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var image: String
    var nutrition: NutritionAPI
    
    static let `pasta` = FoodAPI (
        id: 716429,
        title: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs",
        image: "https://img.spoonacular.com/recipes/716429-556x370.jpg",
        nutrition: NutritionAPI(
            nutrients:[
                NutrientAPI(name: "Calories", amount: 543.36, unit: "kcal", percentOFDailyNeeds: 27.17),
                NutrientAPI(name: "Fat", amount: 16.2, unit: "g", percentOFDailyNeeds: 24.93),
                NutrientAPI(name: "Carbohydrates", amount: 83.7, unit: "g", percentOFDailyNeeds: 27.9),
                NutrientAPI(name: "Protein", amount: 16.84, unit: "g", percentOFDailyNeeds: 33.68)
                
            ],
            weightPerServing: WeightAPI(amount:259, unit: "g")
        )
    )
}

