//
//  LittleJournalView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/28/24.
//

import SwiftUI

struct LittleJournalView: View {
    @EnvironmentObject var mu: MonkeyUser
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    LittleJournalView()
        .environmentObject(MonkeyUser())
}
