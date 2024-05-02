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
    @State var currentJournalSize: Int = 0
    
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
                            NavigationLink {
                                FoodSearchView()
                                    .onAppear(){
                                        currentJournalSize = mu.journal.entryLog.count
                                    }
                                    .onDisappear(){
                                        if mu.journal.entryLog.count > currentJournalSize {
                                            Task{
                                                do {
                                                    Text("I'm boutta write to the database")
                                                    if let journalID = mu.journal.id, let entry = mu.journal.entryLog.last {
                                                        try await databaseService.addJournalEntries(documentId: journalID, entry: entry)
                                                    }
                                                } catch{
//                                                    print("ERROR: \(err)")
                                                    print("error occured")
                                                }
                                            }
                                        }
                                    }
                            } label:{
                                Label("Add", systemImage: "plus")
                            }
                            if mu.foodCache.count == 0 {
                                VStack {
                                    Spacer()
                                    Text("There are no foods entered for today.")
                                    Spacer()
                                }
                            } else {
                                List(Array(zip(mu.journal.entryLog.indices, mu.journal.entryLog)), id: \.0) { index, entry in
                                    if let fd = mu.foodCache[entry.food] {
                                        // One gets fixed another thing gets broken. porque
//                                        MacroFoodRow(food: fd, ratio: $mu.journal.entryLog[index].ratio)
                                        Text(fd.name)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                .navigationTitle("Macro Monkey 🙈")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if $auth.user != nil {
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
