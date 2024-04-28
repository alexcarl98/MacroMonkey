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
    @EnvironmentObject var whoeverIsUsingThisMonkey: MonkeyUser

    @Binding var requestLogin: Bool
    @State var journal: Journal
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    
    var body: some View {
            //TODO : This is hardcoded, make it work with normal ass values
            NavigationView {
                VStack {
                    NutritionGraph(current: journal.getTotalMacros(), goals: whoeverIsUsingThisMonkey.profile.goalMacros())
                    Divider()
                    if fetching {
                        ProgressView()
                    } else if error != nil {
                        Text("Something went wrong…we wish we can say more 🤷🏽")
                    } else {
                        VStack {
                            NavigationLink{
                                FoodSearchView()
                            } label:{
                                Label("Add", systemImage: "plus")
                            }
                            if journal.entryLog.count == 0 {
                                VStack {
                                    Spacer()
                                    Text("There are no foods entered for today.")
                                    Spacer()
                                }
                            } else {
                                List(journal.entryLog.indices, id: \.self) { index in
    //                            Text(journal.entryLog[index].food.name)
//                                    print(journal.entryLog[index].ratio)
//                                    let _ = print(journal.entryLog[index].ratio)
                                    MacroFoodRow(food: journal.entryLog[index].food, ratio: $journal.entryLog[index].ratio)
            //                        NavigationLink {
            //                            ArticleDetail(article: article)
            //                        } label: {
            //                            ArticleMetadata(article: article)
            //                        }
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
            .task {
                fetching = true
                do {
                    // SEE TODO.md
//                    foods = try await databaseService.fetchFoods()
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
                }
            }
        }
}


struct FoodJournalList_Previews: PreviewProvider {
    @State static var requestLogin = false

    static var previews: some View {
        FoodJournalList(requestLogin: $requestLogin, journal: Journal.default)
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(MonkeyUser())
    }
}
