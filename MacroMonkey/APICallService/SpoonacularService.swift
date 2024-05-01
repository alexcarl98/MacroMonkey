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
    
    func performSearch(for query: Int) async -> Food? {
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
}

struct Fd: Codable, Identifiable {
    let id: Int
    let title: String
    // Add other properties as per the API response
}
