//
//  NutritionBar.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import SwiftUI

struct NutritionBar: View {
    var macroNutrient: String
    var amtConsumedSoFar: Float
    var goalConsumption: Float
    var color: Color
    var barHeight: CGFloat = 20
    

    @State private var drawingWidth = false
    @State private var noBar:CGFloat = 0

    var body: some View {
        // Proportion of the value relative to the goal
        let proportion = amtConsumedSoFar / goalConsumption
        // Adjusted width of the bar based on the proportion
        let targetWidth = min(200, proportion * 200)
        
        HStack {
            Text(macroNutrient)
                .frame(width: 80, alignment: .trailing)  // Label for the nutrient
            ZStack(alignment: .leading) {  // Align bars to the leading edge
                Capsule()
                    .frame(width: 200, height: barHeight)
                    .foregroundColor(Color.black.opacity(0.15))  // Invisible placeholder to ensure alignment
                Capsule()
                    .fill(color)
                    .frame(width: drawingWidth ? CGFloat(targetWidth):noBar, height: barHeight)  // Actual bar width
                    .animation(.spring(duration:1, bounce: (targetWidth <= 190.0) ? 0.4:0.1), value:drawingWidth)
                    .foregroundColor(.clear)
//                    .onChange(of: amtConsumedSoFar, perform:{drawingWidth.toggle()})
            
            }
            .onAppear{
                drawingWidth.toggle()
            }
            .onDisappear{
                drawingWidth.toggle()
                noBar = 0
            }
            Text("\(String(format: "%.0f", amtConsumedSoFar))/\n\(String(format: "%.0f", goalConsumption))")
                .font(.footnote)
                .frame(width: 50, alignment: .leading)
        }
    }
}

#Preview {
    NutritionBar(macroNutrient: "Calories", amtConsumedSoFar: 1640.0, goalConsumption: 2500.0, color: Color(hex:"#702963"))
}
