//
//  FoodSearchAPI.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import SwiftUI


struct APIKeyViewHelper: View {
    @EnvironmentObject var Spoonacular: SpoonacularService
    @State private var apiKey: String = ""
    @State private var errorMessage: String?
    
    init() {
        do {
            self.apiKey = try Config.apiKey()
//            print("Retrieved API key: \(self.apiKey)")
        } catch {
            self.apiKey = "default_api_key"  // Use a default or dummy API key
            print("Failed to retrieve API key, using default: \(self.apiKey)")
        }
    }
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
    
}

#Preview {
    APIKeyViewHelper()
}
