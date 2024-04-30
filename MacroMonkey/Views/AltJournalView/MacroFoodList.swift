//
//  MacroFoodList.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct MacroFoodList: View {
    @EnvironmentObject var mu: MonkeyUser
    @EnvironmentObject var dbService: MacroMonkeyDatabase
    
    var body: some View {
        List(mu.journal.entryLog.indices, id: \.self) { index in
            if let food = dbService.foodCache[mu.journal.entryLog[index].food.fid]{
                
                ZStack{
                    MacroFoodRow(food: food, ratio: $mu.journal.entryLog[index].ratio)
                    
                }
                .background(NavigationLink("", destination:FoodDetail(image: food.img, name: food.name, serv: food.servSize, unit: food.servUnit, macros: food.formatted_macros())).opacity(0))
                .listRowInsets(EdgeInsets())
            }
        }
    }
}

#Preview {
    MacroFoodList()
        .environmentObject(MonkeyUser())
        .environmentObject(MacroMonkeyDatabase())
}
