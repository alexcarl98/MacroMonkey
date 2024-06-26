//
//  PlanProgressView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct PlanProgressView: View {
    @EnvironmentObject var mu: MonkeyUser
    
    var body: some View {
        VStack{
            BadgesCollected()
            Divider()
            Section(header: Text("Cycle Days Left: \(mu.profile.daysToDiet)").font(.headline)){
                CalendarBlocks(days: 66 - mu.profile.daysToDiet)
            }
            Divider()
            HStack{
                Stats()
                    .padding()
                Spacer()
            }
        }
    }
}
