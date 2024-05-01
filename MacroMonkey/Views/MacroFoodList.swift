//
//  MacroFoodList.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/30/24.
//

import SwiftUI

struct MacroFoodList: View {
    @EnvironmentObject var mu: MonkeyUser
    
    var body: some View {
           Group {
               if mu.journal.entryLog.count > 0 {
                   listEntries
               } else {
                   Text("We're sorry, we can't show these right now")
               }
           }
       }
       
       private var listEntries: some View {
           List {
               ForEach(Array(mu.journal.entryLog.enumerated()), id: \.element.id) { index, entry in
                   if let food = mu.getFood(foodID: entry.foodId) {
                       ZStack {
                           MacroFoodRow(food: food, ratio: $mu.journal.entryLog[index].ratio)
                               .background(NavigationLink("", destination: FoodDetail(image: food.img, name: food.name, serv: food.servSize, unit: food.servUnit, macros: food.formatted_macros())).opacity(0))
                               .listRowInsets(EdgeInsets())
                       }
                   }
               }
           }
       }
}

#Preview {
    MacroFoodList()
        .environmentObject(MonkeyUser(profile: AppUser.default, journals: [Journal.default], foodCache: [716429: Food.pasta]))
}
