//
//  Home.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var auth: MacroMonkeyAuth
    @State var requestLogin = false
    
    var body: some View {
        if let authUI = auth.authUI {
            FoodJournalList(requestLogin: $requestLogin, foods: [])
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

#Preview {
    Home()
}
