//
//  FoodDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct FoodDetail: View {
    @EnvironmentObject var Spoonacular: SpoonacularService
    
    
    var body: some View {
        ScrollView{
            Text("Hello")
        }
    }
}

#Preview {
    FoodDetail()
}
