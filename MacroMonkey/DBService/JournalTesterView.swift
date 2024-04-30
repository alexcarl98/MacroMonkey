////
////  JournalTesterView.swift
////  MacroMonkey
////
////  Created by Alex Alvarez on 4/28/24.
////
//
//import SwiftUI
//
//struct JournalTesterView: View {
//    @EnvironmentObject var database: MacroMonkeyDatabase
//    @EnvironmentObject var mu: MonkeyUser
//    @State private var userID = "rxKNDDdD8HPi9pLUHtbOu3F178J3"
//    let ids = [635350, 658615, 157106, 1095931]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("User Settings")) {
////                    TextField("User ID", text: $userID)
//                    Button("Fetch User Profile") {
//                        Task {
//                            do {
//                                let user = try await database.fetchUserProfile(userID: mu.profile.uid)
//                                let outputText = "Fetched User: \(user.name)"
//                            } catch {
//                                let outputText = "Error: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                }
//                Section(header: Text("Journal")){
//                    DatePicker("Journal Date", selection: $journalDate, displayedComponents: .date)
//                    HStack{
//                        Text("UserID: \(mu.profile.uid)")
//                    }
//                }
//                Section(header: Text("Entries")) {
//                    HStack {
//                        Text("Food ID: \(String(ids[0]))")
//                    }
//                    HStack {
//                        Text("Ratio:")
//                        TextField("Ratio", value: $ratio, formatter: NumberFormatter())
//                    }
//                    Button("Add Entry") {
//                        Task {
//                            do {
////                                let food = try await database.fetchFoodInfo(foodID: foodID)
//                                let _ = try await database.writeJournal(journal: mu.journal, uid: mu.profile.uid)
//                                outputText = "Entry added successfully"
//                            } catch {
//                                outputText = "Error: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                }
//                Section(header: Text("Output")) {
//                    Text(outputText)
//                        .foregroundColor(.blue)
//                }
//            }
//            .navigationTitle("Journal Tester")
//        }
//    }
//}
//
//#Preview {
//    JournalTesterView()
//        .environmentObject(MacroMonkeyDatabase())
//        .environmentObject(MonkeyUser())
//    
//}
