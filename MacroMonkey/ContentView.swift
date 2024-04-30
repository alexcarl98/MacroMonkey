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
    @State var requestLogin: Bool = false
    @State var isNewUser: Bool = false

    var body: some View {
        if mu.profile.name != "" {
            if !isNewUser {
                let _ = print("User info:\(mu.profile.name)|")
                TabView{
                    FoodJournalList(requestLogin: $requestLogin)
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
            } else {
                ProfileSetup(newUser: $mu.profile, editing: $isNewUser)
            }
        } else {
            if let authUI = auth.authUI {
                
                SignInView(rqst: $requestLogin)
                    .sheet(isPresented: $requestLogin) {
                        ZStack{
                            
                            AuthenticationViewController(authUI: authUI)
                                .onDisappear {
                                    // Functionality to record user information into a 'users' collection
                                    Task {
                                        if !auth.userID.isEmpty {
                                            if try await firebaseServices.userExists(userID: auth.userID){
                                                mu.profile = try await firebaseServices.fetchUserProfile(userID: auth.userID)
                                            } else {
                                                mu.userLoginInfo(userName: auth.userName, userID: auth.userID, email: auth.userEmail)
                                                isNewUser = true
                                            }
                                            print("User: \(mu.profile.name)")
                                        }
                                    }
                                }
                        }
                    }
            } else {
                VStack {
                    Text("Sorry, looks like we aren’t set up right!")
                        .padding()
                    Text("Please contact this app’s developer for assistance.")
                        .padding()
                }
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(SpoonacularService())
        .environmentObject(MonkeyUser())
}
