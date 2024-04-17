//
//  ContentView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentUser: AppUser = AppUser.empty
    var body: some View {
        Home()
    }
}

#Preview {
    ContentView()
        .environmentObject(MacroMonkeyAuth())
        .environmentObject(MacroMonkeyDatabase())
}
