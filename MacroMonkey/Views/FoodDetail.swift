//
//  FoodDetail.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

import SwiftUI

struct FoodDetail: View {
    @State var image: String
    @State var name: String
    @State var serv: Double
    @State var unit: String
    @State var macros: [Double]
    var macroNames = ["Calories", "Fat", "Carbohydrates", "Protein"]
    
    var body: some View {
        VStack{
            AsyncCircleImage(imageName: image)
            Text(name)
                .font(.title2)
                .fontWeight(.bold)
            Text("Serving Size: \(String(format: "%.0f",serv)) \(unit)")
                .font(.headline)
                .foregroundColor(.secondary)
            Divider()
            ForEach(0...3, id:\.self){ macroIndex in
                HStack{
                    Spacer()
                    Text("\(macroNames[macroIndex]): \(String(format: "%.2f", macros[macroIndex]))")
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(1)
                    Spacer()
                }
            }
            Spacer()
        }
    }
}

#Preview {
    FoodDetail(image: "https://img.spoonacular.com/recipes/716429-556x370.jpg", name: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs", serv: 259.0, unit: "g", macros: [543.36, 16.2, 83.7, 16.84])
}
