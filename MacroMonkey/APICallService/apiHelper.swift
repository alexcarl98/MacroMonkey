//
//  apiHelper.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/18/24.
//

import SwiftUI

struct ApiResponse: Codable {
    var products: [Fd]
}

struct apiHelper: View {
    @EnvironmentObject var Spoonacular: SpoonacularService
    @State private var apiKey: String = ""
    @State private var searchText = ""
    @State private var errorMessage: String?
    @State private var searchResults = [Fd]()
    
    
    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("API Key: \(apiKey)")
                    .padding()
                    .border(Color.blue, width: 1)
                    .foregroundColor(.blue)
            }
            Button("Load API Key") {
                loadApiKey()
            }
            NavigationStack {
                List(searchResults){ result in
                    NavigationLink{
                        FoodDetail()
                    } label: {
                        Text(result.title)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a food")
            .onChange(of: searchText) {
                searchResults = [Fd]()
                performSearch(for: searchText)
            }
        }
        .padding()
    }
    
    private func loadApiKey() {
        do {
            let key = try Config.apiKey()
            self.apiKey = key
            self.errorMessage = nil
        } catch ConfigError.missingFile {
            self.errorMessage = "The configuration file is missing."
        } catch ConfigError.dataReadingFailed {
            self.errorMessage = "Failed to read data from the configuration file."
        } catch ConfigError.invalidFormat {
            self.errorMessage = "The format of the configuration file is invalid."
        } catch {
            self.errorMessage = "An unknown error occurred."
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
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                // This filter function is not working, re-write it :
                // Filter products depending on whether they have the keys 'serving_quantity' and 'nutriments'
                let validProducts = decodedResponse.products
                DispatchQueue.main.async {
                    // Update to use validProducts and limit to first 5 results
                    searchResults = Array(validProducts.prefix(10))
                }
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
    }
}

#Preview {
    apiHelper()
        .environmentObject(SpoonacularService())
}
