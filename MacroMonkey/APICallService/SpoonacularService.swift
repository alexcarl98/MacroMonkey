//
//  APIService.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/17/24.
//

import Foundation
import Combine
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
            self.apiKey = "default_api_key"  // Use a default or dummy API key
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
}

struct Fd: Codable, Identifiable {
    let id: Int
    let title: String
    // Add other properties as per the API response
}

//class SpoonacularService: ObservableObject{
//    private var foodsToAdd = [String]()
//    private var API_KEY: String
//    
//    init() {
//        API_KEY = Config.apiKey()
//    }
//        
////    func toggleFoodToAdd(prod: Prod) {
////        let code = prod.code
////        if let index = foodsToAdd.firstIndex(of: code) {
////            foodsToAdd.remove(at: index)
////        } else { foodsToAdd.append(code) }
////    }
//    
//    func performSearch(for query: String) {
////        // Invokes API Call depending on user search
////        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
////            searchResults = [Prod]()
////            return
////        }
////        
////        let urlString = searchString(query)
////        guard let url = URL(string: urlString) else { return }
////        
////        Task {
////            do {
////                let (data, _) = try await URLSession.shared.data(from: url)
////                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
////                // This filter function is not working, re-write it :
////                // Filter products depending on whether they have the keys 'serving_quantity' and 'nutriments'
////                let validProducts = decodedResponse.products.filter {
////                    $0.serving_quantity != nil && $0.nutriments != nil
////                }
////                DispatchQueue.main.async {
////                    // Update to use validProducts and limit to first 5 results
////                    searchResults = Array(validProducts.prefix(10))
////                }
////            } catch {
////                print("Failed to fetch data: \(error)")
////            }
////        }
//    }
//    
//    func submitFoods() {
////        for foodCode in foodsToAdd {
////            if let prod = searchResults.first(where: { $0.code == foodCode }){
////            
////                existingValidFoods.append(prod.toValidFood())  // Directly appending non-optional ValidFood
////            }
////        }
////        foodsToAdd.removeAll()
//    }
//    
//    func searchByIngredientString(_ foodsName: String) -> String {
//        // Function that returns the correct api link
//        let query = foodsName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foodsName
//        return "https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&countries_tags_en=united-states&fields=code,nutriments,generic_name,product_name,serving_quantity,serving_quantity_unit,selected_images,brands,categories_tags_en&categories_tags_en=\(query)&sort_by=nothing"
////        return "https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&countries_tags_en=united-states&fields=code,nutriments,generic_name,product_name,serving_quantity,serving_quantity_unit,selected_images,brands,categories_tags_en&categories_tags_en=orange&sort_by=nothing"
//    }
//    
//    func searchByRecipeString(_ foodsName: String) -> String {
//        // Function that returns the correct api link
//        let query = foodsName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foodsName
//        return "https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&countries_tags_en=united-states&fields=code,nutriments,generic_name,product_name,serving_quantity,serving_quantity_unit,selected_images,brands,categories_tags_en&categories_tags_en=\(query)&sort_by=nothing"
////        return "https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&countries_tags_en=united-states&fields=code,nutriments,generic_name,product_name,serving_quantity,serving_quantity_unit,selected_images,brands,categories_tags_en&categories_tags_en=orange&sort_by=nothing"
//    }
//    
//}
