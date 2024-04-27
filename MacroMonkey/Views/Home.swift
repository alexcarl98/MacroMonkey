//
//  Home.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var auth: MacroMonkeyAuth
    @EnvironmentObject var firebaseServices: MacroMonkeyDatabase
    @State var requestLogin = false
    @State var isNewUser = false
    @State private var currentUser: AppUser = AppUser.empty
    
    var body: some View {
        if let authUI = auth.authUI {
            
            FoodJournalList(requestLogin: $requestLogin, journal: Journal.default)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .sheet(isPresented: $requestLogin) {
                    AuthenticationViewController(authUI: authUI)
                        .onDisappear {
                            // Functionality to record user information into a 'users' collection
                            Task {
                                if !auth.userID.isEmpty {
                                    if try await firebaseServices.userExists(userID: auth.userID){
                                        currentUser = try await firebaseServices.fetchUserProfile(userID: auth.userID)
                                    } else {
                                        currentUser.name = auth.userName
                                        currentUser.uid = auth.userID
                                        currentUser.email = auth.userEmail
                                        isNewUser = true
                                    }
                                    
                                    print("User: \(currentUser.name)")
                                    
                                }
                            }
                        }
                }
                .sheet(isPresented: $isNewUser){
                    ProfileSetup(newUser: $currentUser, editing: $isNewUser)
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

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(MacroMonkeyAuth())
            .environmentObject(MacroMonkeyDatabase())
    }
}
