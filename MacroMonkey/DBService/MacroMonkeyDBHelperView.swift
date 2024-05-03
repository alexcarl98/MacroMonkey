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
    @EnvironmentObject var mu: MonkeyUser

    var body: some View {
        VStack {
            if mu.journal != Journal.empty {
                Text("Journal ID: \(mu.journal.id ?? "N/A")")
                Text("User ID: \(mu.journal.uid)")
                Text("Date: \(mu.journal.journalDate)")

                // Display entry log
                ForEach(mu.journal.entryLog, id: \.self) { entry in
                    Text("Food ID: \(entry.food), Ratio: \(entry.ratio)")
                    Text("Time: \(entry.time)")
                }
            } else {
                Text("Loading journal...")
            }

            Button("Get Journal") {
                fetchJournal()
            }

            Button("Add Entry") {
                addEntry()
            }

            Button("Update First Ratio to 1.3") {
                updateFirstRatio()
            }

            Button("Delete First Element") {
                deleteLastElement()
            }
        }
        .onAppear {
            fetchJournal()
        }
    }

    func fetchJournal() {
        let usid = "hp8IBAp5RzgvtzSPa0klLtz3eB93"
        let journalDate = "05-02-24"
        Task {
            do {
                mu.journal = try await mdb.getJournal(withId: usid, on: journalDate)
            } catch {
                print("Error fetching journal: \(error.localizedDescription)")
            }
        }
    }

    func addEntry() {
        let entry = Entry(food: 123, ratio: 1.1)
        Task {
            do {
                try await mdb.addEntryToJournal(journalID: mu.journal.id ?? "", ent: entry)
                mu.journal.entryLog.append(entry)
            } catch {
                print("Error adding entry: \(error.localizedDescription)")
            }
        }
    }

    func updateFirstRatio() {
//        mu.journal.entryLog
        mu.journal.entryLog[0].ratio = 1.3
        updateEntries(entries: mu.journal.entryLog)
    }

    func deleteLastElement() {
        mu.journal.entryLog.removeFirst()
        updateEntries(entries: mu.journal.entryLog)
    }

    func updateEntries(entries: [Entry]) {
        Task {
            do {
                try await mdb.updateEntries(journalID: mu.journal.id ?? "", entries: entries)
            } catch {
                print("Error updating entries: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MacroMonkeyDBHelperView()
        .environmentObject(MacroMonkeyDatabase())
        .environmentObject(SpoonacularService())
        .environmentObject(MonkeyUser(profile:AppUser.empty, journals:[Journal.empty], foodCache:[:]))
}
