//
//  File.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.


import Foundation

struct NutrientAPI: Hashable, Codable{
    var name: String
    var amount: Float
    var unit: String
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
                NutrientAPI(name: "Calories", amount: 543.36, unit: "kcal"),
                NutrientAPI(name: "Fat", amount: 16.2, unit: "g"),
                NutrientAPI(name: "Carbohydrates", amount: 83.7, unit: "g"),
                NutrientAPI(name: "Protein", amount: 16.84, unit: "g")
            ],
            weightPerServing: WeightAPI(amount:259, unit: "g")
        )
    )
    func convertToFood() -> Food{
        let cals = nutrition.nutrients.first { $0.name == "Calories" }?.amount ?? 0.0
        let protein = nutrition.nutrients.first { $0.name == "Protein" }?.amount ?? 0.0
        let carbs = nutrition.nutrients.first { $0.name == "Carbohydrates" }?.amount ?? 0.0
        let fats = nutrition.nutrients.first { $0.name == "Fat" }?.amount ?? 0.0

        // where name == "Calories"
        return Food(
            id: self.id,
            name: self.title,
            servSize: self.nutrition.weightPerServing.amount,
            servUnit: self.nutrition.weightPerServing.unit,
            nutrients: Nutrient(
                cals: cals,
                protein: protein,
                carbs: carbs,
                fats: fats),
            img: self.image
        )
    }
}
