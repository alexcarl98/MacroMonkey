//
//  MonkeyUser.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

import SwiftUI


class MonkeyUser: ObservableObject {
    @Published var profile: AppUser
    @Published var journals: [Journal]
    @Published var foodCache: [Int: Food]
    @Published var journal: Journal = Journal.default
    

    init(profile: AppUser, journals: [Journal], foodCache: [Int: Food]) {
        self.profile = profile
        self.journals = journals
        self.foodCache = foodCache
        if journals.count > 0 {
            if let journ = journals.last{
                self.journal = journ
            }
        }
    }
    
    func addFood(_ food: Food){
//        objectWillChange.send()
        foodCache[food.id] = food
        journal.addFoodEntry(food)
    }
    
    func rmvFood(_ idx: Int){
//        objectWillChange.send()
        journal.removeFoodByIndex(idx)
    }
    
//    func updateUI(){
//        objectWillChange.send()
//    }
    
    func userLoginInfo(userName: String, userID: String, email: String) {
//        objectWillChange.send()
        profile.name = userName
        profile.uid = userID
        profile.email = email
    }
    
    func getFood(foodID:Int) -> Food? {
        return foodCache[foodID]
    }
    
    func getTotalMacros() -> [Double] {
        var totals: [Double] = [0.0, 0.0, 0.0, 0.0]
        for entry in journal.entryLog {
            totals[0] += (foodCache[entry.food]?.cals ?? 0) * entry.ratio
            totals[1] += (foodCache[entry.food]?.protein ?? 0) * entry.ratio
            totals[2] += (foodCache[entry.food]?.carbs ?? 0) * entry.ratio
            totals[3] += (foodCache[entry.food]?.fats ?? 0) * entry.ratio
        }
        return totals
    }
    
    func getFoodByIndex(at index: Int) -> Food? {
        let foodID = journal.entryLog[index].food
        return foodCache[foodID]
    }
    
    
}

