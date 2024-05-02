//
//  APIService.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import Foundation
import Combine
import SwiftUI


/*
 * This is a lot of stuff from the Other API that was using the OpenFoodAPI calls.
 * TODO: Modify this code to match
 *   [Mismatching Objects]
 *      - Prod:
 *      - searchResults:
 *      - ApiResponse:
 *      - existingValidFoods:
 */
let FOOD_PAGE_LIMIT = 20

class SpoonacularService: ObservableObject {
    private var apiKey: String
    // Non-throwing initializer
    
    init() {
        do {
            self.apiKey = try Config.apiKey()
        } catch {
            self.apiKey = "35a34040989f487980190fd6f63453a3"  // Use a default or dummy API key
            print("Failed to retrieve API key, using default: \(self.apiKey)")
        }
    }
    
    func fetchRecipes(completion: @escaping (Result<[Fd], Error>) -> Void) {
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey)&query=pasta"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            do {
                let recipes = try JSONDecoder().decode([Fd].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(recipes))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func queryByFoodNameString(_ foodsName: String) -> String {
        let query = foodsName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foodsName
        return "https://api.spoonacular.com/recipes/complexSearch?apiKey=\(apiKey)&query=\(query)&number=\(FOOD_PAGE_LIMIT)"
    }
    
    func queryByFoodIDString(_ foodID: Int) -> String {
        return "https://api.spoonacular.com/recipes/\(foodID)/information?apiKey=\(apiKey)&includeNutrition=true"
    }
    
    func queryByFoodIDInBulk(_ foodID: [Int]) -> String {
        let ids = foodID.map(String.init).joined(separator: ",")
        return "https://api.spoonacular.com/recipes/informationBulk?apiKey=\(apiKey)&ids=\(ids)&includeNutrition=true"
    }
    
    func performSearch(for query: Int) async -> Food? {
        // TODO: modify this function to accept an array of ints and call the queryByFoodIDInBulk
        let urlString = queryByFoodIDString(query)
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            var decodedResponse = try JSONDecoder().decode(FoodAPI.self, from: data)
            decodedResponse.filterFood()
            let food = decodedResponse.convertToFood()
            print("Found food : \(food.name)")
            return food
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getListOfFoodsFromBulk(bulk: [FoodAPI]) -> [Food]{
        var fds = [Food]()
        for food in bulk {
            let cals = food.nutrition.nutrients.first {$0.name == "Calories" }?.amount ?? 0.0
            let protein = food.nutrition.nutrients.first { $0.name == "Protein" }?.amount ?? 0.0
            let carbs = food.nutrition.nutrients.first { $0.name == "Carbohydrates" }?.amount ?? 0.0
            let fats = food.nutrition.nutrients.first { $0.name == "Fat" }?.amount ?? 0.0
            fds.append(Food(
                id: food.id,
                name: food.title,
                servSize: Double(food.nutrition.weightPerServing.amount),
                servUnit: food.nutrition.weightPerServing.unit,
                cals: Double(cals),
                protein: Double(protein),
                carbs: Double(carbs),
                fats: Double(fats),
                img: food.image
            ))
        }
        return fds
    }
    
    func performBulkSearch(for queries: [Int]) async -> [Food]? {
        // Construct the query URL for bulk search
        let urlString = queryByFoodIDInBulk(queries)
        guard let url = URL(string: urlString) else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([FoodAPI].self, from: data)
            decodedResponse.forEach { food in
                print("Found food : \(food.title)")
            }
            return getListOfFoodsFromBulk(bulk: decodedResponse)
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}

struct Fd: Codable, Identifiable {
    let id: Int
    let title: String
    // Add other properties as per the API response
}

