//
//  apiHelper.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/18/24.
//

import SwiftUI

struct ApiResponse: Codable {
    var results: [Fd]
}

struct FoodSearchView: View {
    @EnvironmentObject var Spoonacular: SpoonacularService
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var errorMessage: String?
    @State private var searchResults = [Fd]()
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                List(searchResults) { result in
                    NavigationLink {
                        FoodAPIDetail(foodID: result.id)
                    } label: {
                        Text(result.title)
                    }
                }
            }
//            .padding()
        }
        .searchable(text: $searchText, prompt: "Search for a food")
        .onChange(of: searchText) {
            searchResults = []
            performSearch(for: searchText)
        }
    }

    
    func performSearch(for query: String) {
        // Invokes API Call depending on user search
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = [Fd]()
            return
        }
        
        let urlString = Spoonacular.queryByFoodNameString(query)
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true  // Start loading
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                // This filter function is not working, re-write it :
                // Filter products depending on whether they have the keys 'serving_quantity' and 'nutriments'
                let validProducts = decodedResponse.results
                DispatchQueue.main.async {
                    // Update to use validProducts and limit to first 5 results
                    searchResults = Array(validProducts.prefix(10))
                    isLoading = false  // Stop loading
                }
            } catch {
                DispatchQueue.main.async{
                    isLoading = false  // Stop loading even on failure
                }
            }
        }
    }
}
//
//#Preview {
//    FoodSearchView()
//        .environmentObject(SpoonacularService())
//        .environmentObject(MonkeyUser())
//}
