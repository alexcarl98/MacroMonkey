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
    
    func formatted() -> String {
        return "\(name): \(String(format: "%.0f", amount)) \(unit)"
    }
}

struct WeightAPI: Hashable, Codable{
    var amount: Float
    var unit: String
    
    func formatted() -> String {
        return "Serving Size: \(String(format: "%.0f", amount)) \(unit)"
    }
}

struct NutritionAPI: Hashable, Codable {
    var nutrients: [NutrientAPI]
    var weightPerServing: WeightAPI
    
    func formatted() -> [Float] {
        return [nutrients[0].amount, nutrients[1].amount, nutrients[2].amount, nutrients[3].amount]
    }
    func formattedDbl() -> [Double] {
        return [Double(nutrients[0].amount), Double(nutrients[1].amount), Double(nutrients[2].amount), Double(nutrients[3].amount)]
    }
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
    
    mutating func filterFood() {
        let macrosToDisplay = ["Calories", "Fat", "Protein", "Carbohydrates"]
        var filtered = [NutrientAPI]()
        filtered = nutrition.nutrients.filter{ macrosToDisplay.contains($0.name) }
        nutrition.nutrients = filtered
    }
    
    func convertToFood() -> Food{
        let cals = nutrition.nutrients.first { $0.name == "Calories" }?.amount ?? 0.0
        let protein = nutrition.nutrients.first { $0.name == "Protein" }?.amount ?? 0.0
        let carbs = nutrition.nutrients.first { $0.name == "Carbohydrates" }?.amount ?? 0.0
        let fats = nutrition.nutrients.first { $0.name == "Fat" }?.amount ?? 0.0
        // where name == "Calories"
        return Food(
            id: self.id,
            name: self.title,
            servSize: Double(self.nutrition.weightPerServing.amount),
            servUnit: self.nutrition.weightPerServing.unit,
            cals: Double(cals),
            protein: Double(protein),
            carbs: Double(carbs),
            fats: Double(fats),
            img: self.image
        )
    }
}
