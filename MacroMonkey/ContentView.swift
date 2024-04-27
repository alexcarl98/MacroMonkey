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
        .environmentObject(SpoonacularService())
}
