//
//  FoodJournalList.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

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
                    // TODO: Get this to stay consistent to reflect mu.journal values
                    NutritionGraph(current: mu.journal.getTotalMacros(), goals: mu.profile.goalMacros())
                    Divider()
                    if fetching {
                        ProgressView()
                    } else if error != nil {
                        Text("Something went wrong…we wish we can say more 🤷🏽")
                    } else {
                        VStack {
                            foodSearchLink
                            if mu.journal.entryLog.count == 0 {
                                VStack {
                                    Spacer()
                                    Text("There are no foods entered for today.")
                                    Spacer()
                                }
                            } else {
                                journalFoodList
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
            .task {
                fetching = true
                do {
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
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
    
    var journalFoodList: some View {
        // TODO: Get values in here to stay consistent after adding another entry log
        List(mu.journal.entryLog.indices, id: \.self) { index in
            ZStack{
                MacroFoodRow(food: mu.journal.entryLog[index].food, ratio: $mu.journal.entryLog[index].ratio)
                
            }
            .background(NavigationLink("", destination:FoodDetail(image: mu.journal.entryLog[index].food.img, name: mu.journal.entryLog[index].food.name, serv: mu.journal.entryLog[index].food.servSize, unit: mu.journal.entryLog[index].food.servUnit, macros: mu.journal.entryLog[index].food.formatted_macros())).opacity(0))
            .listRowInsets(EdgeInsets())
        }
    }
}


struct FoodJournalList_Previews: PreviewProvider {
    @State static var requestLogin = false

    static var previews: some View {
        FoodJournalList(requestLogin: $requestLogin)
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(MonkeyUser())
    }
}
