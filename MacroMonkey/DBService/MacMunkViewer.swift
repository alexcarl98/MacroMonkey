//
//  MacMunkViewer.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/30/24.
//

import SwiftUI

struct MacMunkViewer: View {
    @EnvironmentObject var dbservice: MacMunkDB
    @State private var documentId = "Rm8vw8NBGWvvWMDQYy1x"  // Placeholder for document ID input
    @State var fetching = false
        var body: some View {
            NavigationView {
                VStack {
                    TextField("Enter Document ID", text: $documentId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Fetch Journal") {
                        dbservice.fetchJournal(documentId: documentId)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)

                    if let journal = dbservice.journal {
                        Text("Journal ID: \(journal.id ?? "N/A")")
                        Text("User ID: \(journal.uid)")
                        Text("Journal Date: \(journal.date, formatter: dateFormatter)")
                        if let entries = journal.entries {
                            ForEach(entries, id: \.self) { entry in
                                VStack(alignment: .leading) {
                                    Text("Food ID: \(entry.foodID)")
                                    Text("Alt Food ID: \(entry.altfid)")
                                    Text("Ratio: \(entry.ratio)")
                                    Text("Time: \(entry.time, formatter: timeFormatter)")
                                }
                            }
                        } else {
                            Text("No entries")
                        }
                    }

                    if let error = dbservice.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                    }
                }
                .navigationTitle("Journal Details")
                .padding()
            }
        }

        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }

        var timeFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }
}

#Preview {
    MacMunkViewer()
        .environmentObject(MacMunkDB())
}
