//
//  FoodAPIDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct FoodAPIDetail: View {
    // TODO: Change foodToDisplay into:: @State private var foodToDisplay: Food?
    @EnvironmentObject var spoonacularService: SpoonacularService
    @EnvironmentObject var firebaseService: MacroMonkeyDatabase
    @EnvironmentObject var whoeverIsUsingThisMonkey: MonkeyUser
    @State private var foodToDisplay: FoodAPI?  // Now optional
    @State private var foodFromDb: Food = Food.empty
    @State private var isLoading: Bool = true
    var foodID: Int
    
    var body: some View {
        ScrollView {
            if let food = foodToDisplay {
                FoodDetail(image: food.image, name: food.title, serv: food.nutrition.weightPerServing.amount, unit: food.nutrition.weightPerServing.unit, macros: food.nutrition.formatted())
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
            isLoading = true
            performSearch(for: foodID)
        }
    }

    func performSearch(for query: Int) {
//        Task {
//            //ERROR : Initializer for conditional binding must have Optional type, not 'Food'
//            if let foodInfo = try? await firebaseService.fetchFoodInfo(foodID: query) {
//                DispatchQueue.main.async {
//                    foodFromDb = foodInfo
//                    isLoading = false
//                    return
//                }
//            } else {
//                fetchFromSpoonacular(for: query)
//            }
//        }
        let urlString = spoonacularService.queryByFoodIDString(query)
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(FoodAPI.self, from: data)
                DispatchQueue.main.async {
                    foodToDisplay = decodedResponse
                    foodToDisplay?.filterFood()
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    func fetchFromSpoonacular(for query: Int) {
        let urlString = spoonacularService.queryByFoodIDString(query)
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(FoodAPI.self, from: data)
                DispatchQueue.main.async {
                    foodToDisplay = decodedResponse
                    foodToDisplay?.filterFood()
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    FoodAPIDetail(foodID: 716429)
        .environmentObject(SpoonacularService())
        .environmentObject(MonkeyUser())
        .environmentObject(MacroMonkeyDatabase())
}
