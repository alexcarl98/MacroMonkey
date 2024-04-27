//
//  FoodDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct FoodDetail: View {
    @EnvironmentObject var spoonacularService: SpoonacularService
    @State private var foodToDisplay: FoodAPI?  // Now optional
    @State private var isLoading: Bool = true
    @State private var macrosToDisplay = ["Calories", "Fat", "Protein", "Carbohydrates"]
    var foodID: Int
    
    var filteredNutrients: [NutrientAPI] {
        guard let nutrients = foodToDisplay?.nutrition.nutrients else {
            return []
        }
        return nutrients.filter { macrosToDisplay.contains($0.name) }
    }
    
    var body: some View {
        ScrollView {
            if let food = foodToDisplay {
                VStack {
                    AsyncCircleImage(imageName: food.image)
                    Text(food.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Serving Size: \(String(format: "%.0f", food.nutrition.weightPerServing.amount)) \(food.nutrition.weightPerServing.unit)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Divider()
                    Text("\(filteredNutrients[0].name): \(String(format: "%.0f", filteredNutrients[0].amount)) \(filteredNutrients[0].unit)")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(3)
                    Text("\(filteredNutrients[1].name): \(String(format: "%.0f", filteredNutrients[1].amount)) \(filteredNutrients[1].unit)")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(3)
                    Text("\(filteredNutrients[2].name): \(String(format: "%.0f", filteredNutrients[2].amount)) \(filteredNutrients[2].unit)")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(3)
                    Text("\(filteredNutrients[3].name): \(String(format: "%.0f", filteredNutrients[3].amount)) \(filteredNutrients[3].unit)")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(3)
                }
            } else if isLoading {
                // Display a loading indicator while fetching data
                ProgressView()
            } else {
                // Display a message if no data is available
                Text("No food details available.")
                    .fontWeight(.bold)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isLoading = true  // Start loading
            performSearch(for: foodID)
        }
    }

    func performSearch(for query: Int) {
        // NOTE: There are no errors from the urlString, it's retrieving the correct string (tested in Postman)
        let urlString = spoonacularService.queryByFoodIDString(query)

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                let decodedResponse = try JSONDecoder().decode(FoodAPI.self, from: data)
                
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("JSON String: \(jsonString)")
//                } else{
//                    print("decoded")
//                }
                
                DispatchQueue.main.async {
                    foodToDisplay = decodedResponse
                    isLoading = false  // Stop loading
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false  // Stop loading even on failure
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    FoodDetail(foodID: 716429)
        .environmentObject(SpoonacularService())
}
