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
    
    func addFood(_ food: Food){
        objectWillChange.send()
        journal.addFoodEntry(food)
    }
    
    func rmvFood(_ idx: Int){
        objectWillChange.send()
        journal.removeFoodByIndex(idx)
    }
    
    func updateUI(){
        objectWillChange.send()
    }
}

