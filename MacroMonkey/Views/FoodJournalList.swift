//
//  FoodJournalList.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI
import FirebaseFirestore
import Firebase

struct FoodJournalList: View {
    @EnvironmentObject var auth: MacroMonkeyAuth
    @EnvironmentObject var databaseService: MacroMonkeyDatabase
    @EnvironmentObject var mu: MonkeyUser

    @Binding var requestLogin: Bool
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    var body: some View {
            NavigationStack {
                VStack {
                    NutritionGraph(current: mu.getTotalMacros(), goals: mu.profile.goalMacros())
                    Divider()
                    if fetching {
                        ProgressView()
                    } else if error != nil {
                        Text("Something went wrong…we wish we can say more 🤷🏽")
                    } else {
                        VStack {
                            foodSearchLink
                            if mu.foodCache.count == 0 {
                                VStack{
                                    Spacer()
                                    Text("There are no foods entered for today.")
                                    Spacer()
                                }
                            } else {
                                List(Array(zip(mu.journal.entryLog.indices, mu.journal.entryLog)), id: \.0) { index, entry in
                                    if let fd = mu.foodCache[entry.food] {
                                        // One gets fixed another thing gets broken. porque
//                                        ZStack {
                                        MacroFoodRow(food: fd, ratio: $mu.journal.entryLog[index].ratio)
//                                        }
//                                        .background(NavigationLink("", destination: FoodDetail(image: fd.img, name: fd.name, serv: fd.servSize, unit: fd.servUnit, macros: fd.formatted_macros())).opacity(0))
//                                        .listRowInsets(EdgeInsets())
                                    }
                                }
                            }
                            
                        }
                    }
                }
                .navigationTitle("Macro Monkey 🙈")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if auth.user != nil {
                            Button("New Article") { writing = true }
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if auth.user != nil {
                            Button("Sign Out") {
                                do {
                                    try auth.signOut()
                                } catch {
                                    // No error handling in the sample, but of course there should be
                                    // in a production app.
                                }
                            }
                        } else {
                            Button("Sign In") {
                                requestLogin = true
                            }
                        }
                    }
                    
                }
            }
        }
    
    var foodSearchLink: some View{
        Group {
            NavigationLink {
                FoodSearchView()
            } label:{
                Label("Add", systemImage: "plus")
            }
        }
    }
    
//    var journalFoodList: some View {
//        List(Array(mu.journal.entryLog.enumerated()), id: \.offset) { index, entry in
//            if let food = mu.foodCache[entry.food] {
//                ZStack {
//                    MacroFoodRow(food: food, ratio: $mu.journal.entryLog[index].ratio)
//                }
//                .background(NavigationLink("", destination:FoodDetail(image: food.img, name: food.name, serv: food.servSize, unit: food.servUnit, macros: food.formatted_macros())).opacity(0))
//                .listRowInsets(EdgeInsets())
//            }
//        }
//        .navigationTitle("Food Entries")
//        .navigationBarTitleDisplayMode(.inline)
//    }
}


struct FoodJournalList_Previews: PreviewProvider {
    @State static var requestLogin = false

    static var previews: some View {
        FoodJournalList(requestLogin: $requestLogin)
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(MonkeyUser(profile: AppUser.default, journals: [Journal.default], foodCache: [716429: Food.pasta]))
    }
}
