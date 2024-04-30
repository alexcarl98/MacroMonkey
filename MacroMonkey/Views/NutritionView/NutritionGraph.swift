//
//  NutritionGraph.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import SwiftUI

struct NutritionGraph: View {
    var current: [Double]
    var goals: [Float]
    
    var body: some View {
        VStack {
            NutritionBar(macroNutrient: "Calories", amtConsumedSoFar: current[0], goalConsumption: Double(goals[0]), color: CALORIES_COLOR)
            NutritionBar(macroNutrient: "Protein", amtConsumedSoFar: current[1], goalConsumption: Double(goals[1]), color: PROTEIN_COLOR)
            NutritionBar(macroNutrient: "Carbs", amtConsumedSoFar: current[2], goalConsumption: Double(goals[2]), color: CARBS_COLOR)
            NutritionBar(macroNutrient: "Fats", amtConsumedSoFar: current[3], goalConsumption: Double(goals[3]), color: FATS_COLOR)
        }
    }
}

#Preview {
    NutritionGraph(current: [1159.0, 65, 103.0, 61.0], goals: [2500.0, 141.0, 344.0, 76.0])
}
