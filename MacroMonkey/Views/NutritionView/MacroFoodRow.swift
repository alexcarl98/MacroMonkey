//
//  MacroFoodRow.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import SwiftUI

struct MacroFoodRow: View {
    @State var food: Food
    @Binding var ratio: Float
    @State private var quantity: Float = 0.0
    
    private var macros: [Float] {
        ratio = quantity/food.servSize
        return [
            food.nutrients.cals * ratio,
            food.nutrients.protein * ratio,
            food.nutrients.carbs * ratio,
            food.nutrients.fats * ratio
        ]
    }
    
    
    var body: some View {
        VStack{
            Text(food.name)
                .bold()
                .padding(6)
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color(hex:"#0090FF"), Color(hex:"#6A5ACD")]), startPoint: .top, endPoint: .bottom))
            HStack{
                TextField("(\(food.servUnit))", value: $quantity, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .frame(width: 50)
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                MacroValueCell(value:macros[0], col: CALORIES_COLOR)
                MacroValueCell(value:macros[1], col: PROTEIN_COLOR)
                MacroValueCell(value:macros[2], col: CARBS_COLOR)
                MacroValueCell(value:macros[3], col: FATS_COLOR)
            }
            .frame(height:45)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex:"#EEEEEE"), Color(hex:"#F0F0F0")]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(10)
        .onAppear{
            quantity = ratio * food.servSize
        }
    }
}

#Preview {
    MacroFoodRow(food: Food.pasta, ratio: .constant(1.0))
}
