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
    @State private var currentUser: AppUser = AppUser.empty
    
    var body: some View {
        if let authUI = auth.authUI {
            
            FoodJournalList(requestLogin: $requestLogin, foods: [])
                .tabItem {
                    Label("Home", systemImage: "house.fill" )
                }
                .sheet(isPresented: $requestLogin) {
                    AuthenticationViewController(authUI: authUI)
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

struct Blog_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .environmentObject(MacroMonkeyAuth())
            .environmentObject(MacroMonkeyDatabase())
    }
}
