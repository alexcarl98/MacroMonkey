//
//  MonkeyUser.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

import SwiftUI


class MonkeyUser: ObservableObject {
    @Published var profile: AppUser = AppUser.empty
    @Published var journal: Journal = Journal.empty
    @Published var foodCache: [Int:Food] = [:]
    
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
    
    func userLoginInfo(userName: String, userID: String, email: String) {
        objectWillChange.send()
        profile.name = userName
        profile.uid = userID
        profile.email = email
    }
    
}

