//
//  NutritionGraph.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import SwiftUI

struct NutritionGraph: View {
    var current: [Float]
    var goals: [Float]
    
    var body: some View {
        VStack{
            NutritionBar(macroNutrient: "Calories", amtConsumedSoFar: current[0], goalConsumption: goals[0], color: Color(hex:"#702963"))
            NutritionBar(macroNutrient: "Protein", amtConsumedSoFar: current[1], goalConsumption: goals[1], color: Color(hex:"#009688"))
            NutritionBar(macroNutrient: "Carbs", amtConsumedSoFar: current[2], goalConsumption: goals[2], color: Color(hex:"#4169E1"))
            NutritionBar(macroNutrient: "Fats", amtConsumedSoFar: current[3], goalConsumption: goals[3], color: Color(hex:"#E97120"))
        }
    }
}



#Preview {
    NutritionGraph(current: [1159.0, 65, 103.0, 61.0], goals: [2500.0, 141.0, 344.0, 76.0])
}
