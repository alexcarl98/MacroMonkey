//
//  ContentView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/9/24.
//

import SwiftUI

let CALORIES_COLOR = Color(hex: "#702963")
let PROTEIN_COLOR = Color(hex: "#009688")
let FATS_COLOR = Color(hex: "#E97120")
let CARBS_COLOR = Color(hex:"#4169E1")



func formatDate(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yy"
    return formatter.string(from: date)
}

struct ContentView: View {
    @EnvironmentObject var auth: MacroMonkeyAuth
    @EnvironmentObject var firebaseServices: MacroMonkeyDatabase
    @EnvironmentObject var spoonacularService: SpoonacularService
    @EnvironmentObject var mu: MonkeyUser
    @State var requestLogin = false
    @State var fetching = false
    @State var isNewUser = false

    var body: some View {
        
//        if let authUI = auth.authUI {
        TabView{
            if fetching
            Home()
                .tabItem{
                    Label("Home", systemImage: "house.fill")
                }
                
            PlanProgressView()
                .tabItem{
                    Label("Progress", systemImage: "chart.bar")
                }
            Profile()
                .tabItem{
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .onApper{
            fetching = true
            try {
                
                let journal = try await fetchJournal(auth)
            }
            // ❷ Check if today's journal exists:
            // i.e. try to get the journalID for the journal corresponding to this user's uid and the current date
            // otherwise build out the journal,
            // then: try and get the entries that match the JournalID
        }
//        } else {
//            SignInView()
//        }
    }
}


#Preview {
    ContentView()
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(SpoonacularService())
        .environmentObject(MonkeyUser())
}
