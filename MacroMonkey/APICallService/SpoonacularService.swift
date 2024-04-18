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

class SpoonacularService: ObservableObject{
    private var foodsToAdd = [String]()
    
    
    
    func toggleFoodToAdd(prod: Prod) {
        let code = prod.code
        if let index = foodsToAdd.firstIndex(of: code) {
            foodsToAdd.remove(at: index)
        } else { foodsToAdd.append(code) }
    }
    
    func performSearch(for query: String) {
        // Invokes API Call depending on user search
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = [Prod]()
            return
        }
        
        let urlString = searchString(query)
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                // This filter function is not working, re-write it :
                // Filter products depending on whether they have the keys 'serving_quantity' and 'nutriments'
                let validProducts = decodedResponse.products.filter {
                    $0.serving_quantity != nil && $0.nutriments != nil
                }
                DispatchQueue.main.async {
                    // Update to use validProducts and limit to first 5 results
                    searchResults = Array(validProducts.prefix(10))
                }
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
    }
    
    func submitFoods() {
        for foodCode in foodsToAdd {
            if let prod = searchResults.first(where: { $0.code == foodCode }){
            
                existingValidFoods.append(prod.toValidFood())  // Directly appending non-optional ValidFood
            }
        }
        foodsToAdd.removeAll()
    }
    
    func searchString(_ foodsName: String) -> String {
        // Function that returns the correct api link
        let query = foodsName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foodsName
        return "https://world.openfoodfacts.net/api/v2/search?nutrition_grades_tags=c&countries_tags_en=united-states&fields=code,nutriments,generic_name,product_name,serving_quantity,serving_quantity_unit,selected_images,brands,categories_tags_en&categories_tags_en=\(query)&sort_by=nothing"
    }
}
