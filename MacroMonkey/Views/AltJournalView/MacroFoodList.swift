//
//  MacroFoodList.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct MacroFoodList: View {
    @EnvironmentObject var mu: MonkeyUser
    
    var body: some View {
        List(mu.journal.entryLog.indices, id: \.self) { index in
            ZStack{
                MacroFoodRow(food: mu.journal.entryLog[index].food, ratio: $mu.journal.entryLog[index].ratio)
                
            }
            .background(NavigationLink("", destination:FoodDetail(image: mu.journal.entryLog[index].food.img, name: mu.journal.entryLog[index].food.name, serv: mu.journal.entryLog[index].food.servSize, unit: mu.journal.entryLog[index].food.servUnit, macros: mu.journal.entryLog[index].food.formatted_macros())).opacity(0))
            .listRowInsets(EdgeInsets())
        }
    }
}

#Preview {
    MacroFoodList()
        .environmentObject(MonkeyUser())
}
