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
    @Binding var editing: Bool
    @State private var userCollectionID = ""
    
    var body: some View {
        VStack{
            ProfileEditor(newUser: $newUser)
            Button {
                userCollectionID = firebaseServices.createUser(user: newUser)
                newUser.id = userCollectionID
                editing = false
            } label:{
                Text("Submit")
//                    .padding()
//                    .background(Color.gray, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}


struct ProfileSetup_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetup(newUser: .constant(AppUser.default), editing: .constant(true))
            .environmentObject(MacroMonkeyDatabase())
    }
}
