//
//  MacroMonkeyDBHelperView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

/*
 Besides user authentication (which I have working) this is pretty much the life cycle of my app
 - Firebase: Authenticates user
 - Add to Firebase[`user`] If first time logging in, firebase call to record initial user info into the `user` collection
 - Add to Firebase[`journal`]: Initialize an instance of a `journal` document in a `journals` collection
 - Update Firebase[`user`]: to include the journal [now I'm realizing there's a more efficient way of doing this by adding the journal first, then the user...]
 - Query SpoonacularAPI: Search for food in a search bar
 - Query Spoonacular: choose from one of the foods, opens a detail view, requiring another SpoonacularAPI call. cache this information.
 - Update Firebase[`journal`]: update the user's journal document, record the foodID, the ratio [serving size] (always initially 1.0) and time of input
 - Update Firebase[`journal`]: whenever a user deletes one of the journal entries or changes the serving amount [`ratio`] of the food.
 */

import SwiftUI

struct MacroMonkeyDBHelperView: View {
    @EnvironmentObject var spn: SpoonacularService
    @EnvironmentObject var mdb: MacroMonkeyDatabase
    @EnvironmentObject var mu: MonkeyUser
    @State private var searchText = ""
    @State var searchResults = [Fd]()
    @State private var foodToDisplay: FoodAPI?  // Now optional
    @State private var searchWorkItem: DispatchWorkItem?
    @State private var foodID:Int = 0

    var body: some View {
        //
        VStack {
            if mu.journal != Journal.empty {
                Text("Journal ID: \(mu.journal.id ?? "N/A")")
                Text("User ID: \(mu.journal.uid)")
                Text("Date: \(mu.journal.journalDate)")

                VStack{
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
                            let maccies = calculateMacros(for: mu.foodCache[mu.journal.entryLog[index].food] ?? Food.empty, with: mu.journal.entryLog[index].ratio)
                            Spacer()
                            Picker("Ratio", selection: $mu.journal.entryLog[index].ratio) {
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
            } else {
                Text("Loading journal...")
            }

            Button("Get Journal") {
                fetchJournal()
            }

            Button("Add Entry") {
                Task{
//                    await addEntry()
                    try await pretendSearchAndAdd(searchString: "Pizza")
                }
            }

//            Button("Update First Ratio to 1.3") {
//                updateFirstRatio()
//            }

            Button("Delete First Element") {
                deleteLastElement()
            }
        }
        .onAppear {
            fetchJournal()
            fetchFoods()
        }
    }
    func fetchFoods() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        let journalDat = formatter.string(from: Date.now)
        var foods:[Food] = [Food]()
        
        Task {
            if let todayJournal = mu.journals.first(where: { $0.journalDate == journalDat }){
                // if there's already a journal, get it
                if todayJournal.entryLog.count != 0 {
                    foods = await spn.performBulkSearch(for: todayJournal.getEntriesInBulk()) ?? [Food]()
                    // Populate the foodCache map
                    for food in foods {
                        mu.foodCache[food.id] = food
                    }
                }
            }
        }
    }
    
    func fetchJournal() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        let journalDate = formatter.string(from: Date.now)
        let usid = "hp8IBAp5RzgvtzSPa0klLtz3eB93"
        var foods:[Food] = [Food]()
        Task {
            do {
                mu.journal = try await mdb.getJournal(withId: usid, on: journalDate)
                
                
                // if there's already a journal, get it
                if mu.journal.entryLog.count != 0 {
                    foods = await spn.performBulkSearch(for: mu.journal.getEntriesInBulk()) ?? [Food]()
                    // Populate the foodCache map
                    for food in foods {
                        mu.foodCache[food.id] = food
                    }
                }
                
            } catch {
                print("Error fetching journal: \(error.localizedDescription)")
            }
        }
    }

//    func addEntry() async {
//        let someFoods = [680975, 635350,658651, 642341]
//        let foodIDtoQuery = someFoods.randomElement()!
//        
//        let foodFromAPI = await spn.performSearch(for: String(foodIDtoQuery))
//        
//    }

    
    func addToList(foodToDisplay: FoodAPI?) async throws{
        // From FoodAPIDetail
        if let fd = foodToDisplay{
            mu.addFood(fd.convertToFood())
            Task{
                do {
                    mu.journal.printNicely()
                    if let journalID = mu.journal.id {
                        print("\(journalID)")
                        let newEntry = Entry(food: fd.id, ratio: 1.0)
                        try await mdb.addEntryToJournal(journalID: journalID, ent: newEntry)
                        mu.journal.entryLog.append(newEntry)
                    }
                } catch{
                    print("OOOOOOOPS didn't record it")
                }
            }
//            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func pretendSearchAndAdd(searchString: String) async throws{
        // From FoodAPIDetail
        do {
            searchResults = await spn.performSearchBar(for: searchString) ?? [Fd]()
            
            let someRandomPick = searchResults.randomElement()
            
            if let searchID = someRandomPick?.id {
                foodID = searchID
                performDetailFoodGetting(for: foodID)
            }
        } catch {
            print("some error happened")
        }
    
    }
    
    func performDetailFoodGetting(for foodID: Int) {
        let _ = print(foodID)
    }
    
    func deleteLastElement() {
        mu.journal.entryLog.removeFirst()
        updateEntries(entries: mu.journal.entryLog)
    }
    
    func updateInFB() {
        updateEntries(entries: mu.journal.entryLog)
    }
    
    func updateEntries(entries: [Entry]) {
        Task {
            do {
                try await mdb.updateEntries(journalID: mu.journal.id ?? "", entries: entries)
            } catch {
                print("Error updating entries: \(error.localizedDescription)")
            }
        }
    }
    func calculateMacros(for food: Food, with quantity: Double) -> [Double] {
//            let ratio = quantity / food.servSize
            return [
                food.cals * quantity,
                food.protein * quantity,
                food.carbs * quantity,
                food.fats * quantity
            ]
        }
    
}

#Preview {
    MacroMonkeyDBHelperView()
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(SpoonacularService())
        .environmentObject(MonkeyUser(profile:AppUser.empty, journals:[Journal.empty], foodCache:[:]))
}
