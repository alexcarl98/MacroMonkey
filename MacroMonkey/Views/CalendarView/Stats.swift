//
//  Stats.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct Stats: View {
    @EnvironmentObject var mu: MonkeyUser
    
    
    var body: some View {
            VStack(alignment:.leading){
                Text("Stats")
                    .font(.headline)
                Text("Height: \((mu.profile.heightString))")
                Text("Weight: \(String(format: "%.0f", (mu.profile.weight))) lbs")
                Text("Days left in cycle: \(mu.profile.daysToDiet)")
                Text("Daily Macro goal: \(String(format: "%.0f", mu.profile.goalCaloricIntake())) kcal")
            }
    }
}

#Preview {
    Stats()
}
