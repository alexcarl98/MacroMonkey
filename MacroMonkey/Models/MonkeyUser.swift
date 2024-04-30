//
//  MonkeyUser.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

import SwiftUI


class MonkeyUser: ObservableObject {
    var profile: AppUser = AppUser.default
    var journal: Journal = Journal.default
    
    
    var foodCache: [Int:Food]=[716429:Food.pasta]
//    var foodCache: [Int:Food]=[:]
    var journalCache:[String: Journal]=[:]
    
    func addFood(_ food: Food){
        objectWillChange.send()
        foodCache[food.id] = food
        journal.addFoodEntry(food)
    }
    
    func rmvFood(_ idx: Int){
        objectWillChange.send()
        journal.removeFoodByIndex(idx)
    }
    
    func updateUI(){
        objectWillChange.send()
    }
    
    func getFood(by index: Int) -> Food? {
        objectWillChange.send()
        return foodCache[journal.entryLog[index].foodID]
    }
    
    func getFoodByID(id: Int) -> Food? {
        objectWillChange.send()
        return foodCache[journal.entryLog[id].foodID]
    }
    
    func getTotalMacros() -> [Float] {
        objectWillChange.send()
        var totals: [Float] = [0.0, 0.0, 0.0, 0.0]
        if foodCache.count != 0 {
            for entry in journal.entryLog {
                let enID = entry.foodID
                let rat = entry.ratio
                totals[0] += foodCache[enID]!.cals * rat
                totals[1] += foodCache[enID]!.protein * rat
                totals[2] += foodCache[enID]!.carbs * rat
                totals[3] += foodCache[enID]!.fats * rat
            }
        }
        return totals
    }
}

