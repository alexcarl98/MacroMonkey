//
//  MacroMonkeyDBHelperView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/27/24.
//

import SwiftUI

struct MacroMonkeyDBHelperView: View {
    @EnvironmentObject var spn: SpoonacularService
    @EnvironmentObject var mdb: MacroMonkeyDatabase
    @State private var journal: Journal?

    var body: some View {
        VStack {
            if let journal = journal {
                Text("Journal ID: \(journal.id ?? "N/A")")
                Text("User ID: \(journal.uid)")
                Text("Date: \(journal.journalDate)")

                // Display entry log
                ForEach(journal.entryLog, id: \.self) { entry in
                    Text("Food ID: \(entry.food)")
                    Text("Ratio: \(entry.ratio)")
                    Text("Time: \(entry.time)")
                }
            } else {
                Text("Loading journal...")
            }
        }
        .onAppear {
            // Fetch journal on app launch
            let journalId = "Lf4xJ5vASOPIp3jaBvFwurUfOUb2"
            Task{
                do {
                    self.journal = try await mdb.getJournal(withId: journalId)
//                    let en = try await mdb.addEntryToJournal()
                } catch {
                    print("error occured")
                }
            }
        }
    }
}

#Preview {
    MacroMonkeyDBHelperView()
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(SpoonacularService())
}
