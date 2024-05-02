//
//  FoodAPIDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct FoodAPIDetail: View {
    @EnvironmentObject var spoonacularService: SpoonacularService
    @EnvironmentObject var firebaseService: MacroMonkeyDatabase
    @EnvironmentObject var mu: MonkeyUser
    @Environment(\.presentationMode) var presentationMode
    @State private var foodToDisplay: FoodAPI?  // Now optional
    @State private var isLoading: Bool = true
    var foodID: Int
    
    var body: some View {
        ScrollView {
            if let food = foodToDisplay {
                VStack{
                    FoodDetail(
                        image: food.image,
                        name: food.title,
                        serv: Double(food.nutrition.weightPerServing.amount),
                        unit: food.nutrition.weightPerServing.unit,
                        macros: food.nutrition.formattedDbl()
                    )
                    Spacer()
                    Button {
                        Task{
                            do {
                                try await addToList()
                                
                            }catch{
                                print("Error occured when trying to add to the list")
                            }
                        }
                    } label: {
                        Text("Add +")
                            .font(.title)
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
    
    func addToList() async throws{
        if let fd = foodToDisplay{
            mu.addFood(fd.convertToFood())
            Task{
                do {
                    if let journalID = mu.journal.id {
                        var newEntry = Entry(food: fd.id, ratio: 1.0)
                        let entryString = firebaseService.writeEntToFB(docID: journalID, entry: newEntry)
                        if let st = entryString {
                            newEntry.id = st
                            mu.journal.entr.append(st)
                        }
                    }
                }
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    func performSearch(for query: Int) {
        let urlString = spoonacularService.queryByFoodIDString(query)
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(FoodAPI.self, from: data)
                foodToDisplay = decodedResponse
                foodToDisplay?.filterFood()
                isLoading = false
            
            } catch {    
                isLoading = false
                print("Error: \(error.localizedDescription)")
                
            }
        }
    }
}

