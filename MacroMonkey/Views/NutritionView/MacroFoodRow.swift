//
//  MacroFoodRow.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/19/24.
//

import SwiftUI

struct MacroFoodRow: View {
    @EnvironmentObject var mu: MonkeyUser
    @State var food: Food
    @Binding var ratio: Double
    @State private var quantity: Double

    // Initialize the state variables with default values using the custom initializer
    init(food: Food, ratio: Binding<Double>) {
        self._food = State(initialValue: food)
        self._ratio = ratio
        self._quantity = State(initialValue: food.servSize * ratio.wrappedValue)  // Set initial quantity to food's servSize
    }

    private var macros: [Double] {
        // Calculate the ratio based on quantity and servSize
        ratio = quantity / food.servSize
        return [
            food.cals * ratio,
            food.protein * ratio,
            food.carbs * ratio,
            food.fats * ratio
        ]
    }

    var body: some View {
        VStack {
            HStack{
                Spacer()
                Text(food.name)
                    .bold()
                    .padding(6)
                    .foregroundColor(.white)
                    .frame(maxWidth:.infinity)
                Spacer()
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex:"#0090FF"), Color(hex:"#6A5ACD")]), startPoint: .top, endPoint: .bottom), in: Rectangle())
            HStack {
                TextField("(\(food.servUnit))", value: $quantity, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .frame(width: 50)
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                    .onSubmit {
                        mu.updateUI()
                    }
                MacroValueCell(value: macros[0], col: CALORIES_COLOR)
                MacroValueCell(value: macros[1], col: PROTEIN_COLOR)
                MacroValueCell(value: macros[2], col: CARBS_COLOR)
                MacroValueCell(value: macros[3], col: FATS_COLOR)
            }
            .frame(height: 45)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex:"#EEEEEE"), Color(hex:"#F2EFED"), .white]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(10)
        .onAppear {
            // Ensure the initial ratio reflects the initialized quantity and servSize
            ratio = quantity / food.servSize
        }
    }
}
