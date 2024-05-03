//
//  ProfileSetup.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/16/24.
//

import SwiftUI

struct ProfileSetup: View {
    @EnvironmentObject var firebaseServices: MacroMonkeyDatabase
    
    @Binding var newUser: AppUser
    @Binding var newJournal: Journal
    @Binding var editing: Bool
    @State private var userCollectionID = ""
    
    var body: some View {
        VStack{
            ProfileEditor(newUser: $newUser)
            Button {
                userCollectionID = firebaseServices.createUser(user: newUser)
                newUser.id = userCollectionID
                newJournal = firebaseServices.createNewJournalForUser(userID: newUser.uid, aid: newUser.id)
                if let str = newJournal.id {
                    newUser.journalIDs.append(str)
                }
                editing = false
            } label:{
                Text("Submit")            }
        }
    }
}

struct ProfileSetup_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetup(newUser: .constant(AppUser.default), newJournal:.constant(Journal.default), editing: .constant(true))
            .environmentObject(MacroMonkeyDatabase())
    }
}
