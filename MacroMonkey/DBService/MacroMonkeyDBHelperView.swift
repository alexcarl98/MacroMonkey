////
////  MacroMonkeyDBHelperView.swift
////  MacroMonkey
////
////  Created by Alex Alvarez on 4/27/24.
////
//
//import SwiftUI
//
//struct MacroMonkeyDBHelperView: View {
//    @EnvironmentObject var mu: MonkeyUser
//    @EnvironmentObject var database: MacroMonkeyDatabase
//    @State private var userID = "rxKNDDdD8HPi9pLUHtbOu3F178J3"
//    @State private var foodID = "716429"
//    @State private var resultMessage = ""
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("User Functions")) {
//                    TextField("Enter User ID", text: $userID)
//                    Button("Fetch User Profile") {
//                        Task {
//                            do {
//                                let user = try await database.fetchUserProfile(userID: userID)
//                                resultMessage = "User: \(user.name), Email: \(user.email)"
//                            } catch {
//                                resultMessage = "Error: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                    Button("Check User Exists") {
//                        Task {
//                            do {
//                                let exists = try await database.userExists(userID: userID)
//                                resultMessage = exists ? "User exists." : "User does not exist."
//                            } catch {
//                                resultMessage = "Error: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                }
//                Section(header: Text("Results")) {
//                    Text(resultMessage)
//                        .foregroundColor(.blue)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                }
//            }
//            .navigationTitle("MacroMonkey Database Helper")
//        }
//    }
//}
////
////
////#Preview {
////    MacroMonkeyDBHelperView()
////        .environmentObject(MacroMonkeyDatabase())
//////        .environmentObject(MonkeyUser())
////}
