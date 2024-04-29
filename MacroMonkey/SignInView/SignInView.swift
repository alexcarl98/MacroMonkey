//
//  SwiftUIView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/29/24.
//

import SwiftUI

struct SignInView: View {
    @State var requestLogin: Bool = false
    
    var body: some View {
        ZStack{
            Color.orange.opacity(0.08).edgesIgnoringSafeArea([.top])
            VStack{
                Image("MacroMonkey")
                    .resizable()
                    .frame(width:90*2, height:80*2)
                Text("Log In Or create an account")
                Button(action: {
                    requestLogin = true
                }, label:{
                    loginBtn
                })
            }
        }
    }
    
    var loginBtn: some View {
        ZStack{
            Text("Login")
                .font(.largeTitle)
                .padding(6)
                .background(.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    SignInView()
}
