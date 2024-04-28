//
//  FoodDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct FoodDetail: View {
    // TODO: Change foodToDisplay into:: @State private var foodToDisplay: Food?
    @EnvironmentObject var spoonacularService: SpoonacularService
    @EnvironmentObject var firebaseService: MacroMonkeyDatabase
    @EnvironmentObject var whoeverIsUsingThisMonkey: MonkeyUser
    @State private var foodToDisplay: FoodAPI?  // Now optional
//    @State private var foodFromDb: Food
    @State private var isLoading: Bool = true
    @State private var notInDatabase = false
    var foodID: Int
    
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
                    ForEach(0...3, id:\.self){ macroIndex in
                        HStack{
                            Text(food.nutrition.nutrients[macroIndex].formatted())
                                .frame(maxWidth: .infinity,alignment: .leading)
                                .padding(3)
                            Spacer()
                        }
                    }
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
            isLoading = true
            performSearch(for: foodID)
        }
    }

    func performSearch(for query: Int) {
        // TODO: First check whether food info is in the firestore
        // foodFromDb = try firestoreService.fetchFoodInfo(foodID: query)
        // if that doesn't work, then do the API Call
        
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
        .environmentObject(MonkeyUser())
        .environmentObject(MacroMonkeyDatabase())
}
