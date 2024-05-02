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
                    NutritionGraph(current: mu.getTotalMacros(), goals: mu.profile.goalMacros())
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
                .toolbar { //TODO: Fix this
                    ToolbarItem(placement: .navigationBarLeading) {

                    if auth.user != nil {
                                Button("New Article") {
                                    writing = true
                                }
                            } else {
                                // Possibly add a button or text here if needed when no user is logged in.
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if let user = auth.user {
                                Button("Sign Out") {
                                    do {
                                        try auth.signOut()
                                    } catch {
                                        self.error = error
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
                    let dateForToday = Date.now
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM-dd-yy"
                    
//                    mu.journal.id = try await (by: mu.profile.uid, journalDate: Date.now, jid: formatter.string(from:dateForToday)) ?? Journal.empty
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
                }
//                mu.updateUI()
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
            if let food = mu.getFood(by: index){
                ZStack {
                    MacroFoodRow(food: food, ratio: $mu.journal.entryLog[index].ratio)
                }
                .background(NavigationLink("", destination:FoodDetail(image: food.img, name: food.name, serv: food.servSize, unit: food.servUnit, macros: food.formatted_macros())).opacity(0))
                .listRowInsets(EdgeInsets())
            }
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
