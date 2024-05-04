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
    @State private var searchWorkItem: DispatchWorkItem?
    
    @Binding var requestLogin: Bool
    @Binding var loggedIn: Bool
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
                                List{
                                    ForEach(mu.journal.entryLog.indices, id: \.self) { index in
                                        let food = mu.foodCache[mu.journal.entryLog[index].food] ?? Food.empty
                                        VStack {
                                            HStack{
                                                Spacer()
                                                Text("\(food.name)")
                                                    .foregroundColor(.white)
                                                Spacer()
                                            }
                                            Text("\(String(format: "%.2f",food.servSize)) \(food.servUnit) / per serving")
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                        }
                                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex:"#0090FF"), Color(hex:"#6A5ACD")]), startPoint: .top, endPoint: .bottom), in: Rectangle())
                                        
                                        HStack {
                                            let maccies = mu.calculateMacros(for: mu.foodCache[mu.journal.entryLog[index].food] ?? Food.empty, with: mu.journal.entryLog[index].ratio)
                                            Spacer()
                                            Picker("", selection: $mu.journal.entryLog[index].ratio) {
                                                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { value in
                                                    Text("\(String(format: "%.2f",value))")
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())

                                            MacroValueCell(value: maccies[0], col: CALORIES_COLOR)
                                            MacroValueCell(value: maccies[1], col: PROTEIN_COLOR)
                                            MacroValueCell(value: maccies[2], col: CARBS_COLOR)
                                            MacroValueCell(value: maccies[3], col: FATS_COLOR)
                                            Spacer()
                                        }
                                    }
                                    .onDelete{ indices in
                                        mu.journal.entryLog.remove(atOffsets: indices)
                                        updateInFB()
                                        
                                    }
                                    .listRowInsets(EdgeInsets())
                                }
                                .onChange(of: mu.journal.entryLog) {
                                    // Cancel the current work item if it exists
                                    searchWorkItem?.cancel()
                                    
                                    // Create a new work item to perform the search
                                    let workItem = DispatchWorkItem {
                                        updateInFB()
                                    }
                                    // Save the new work item and schedule it to run after a delay
                                    searchWorkItem = workItem
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
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
                                    mu.profile = AppUser.empty
                                    mu.journals = [Journal.empty]
                                    mu.journal = Journal.empty
                                    mu.foodCache = [:]
                                    loggedIn = false
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
    func updateInFB() {
        updateEntries(entries: mu.journal.entryLog)
    }
    
    func updateEntries(entries: [Entry]) {
        Task {
            do {
                try await databaseService.updateEntries(journalID: mu.journal.id ?? "", entries: entries)
            } catch {
                print("Error updating entries: \(error.localizedDescription)")
            }
        }
    }
}


struct FoodJournalList_Previews: PreviewProvider {
    @State static var requestLogin = false
    @State static var loggedIn = true

    static var previews: some View {
        FoodJournalList(requestLogin: $requestLogin, loggedIn: $loggedIn)
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(MonkeyUser(profile: AppUser.default, journals: [Journal.default], foodCache: [716429: Food.pasta]))
    }
}
