//
//  SwiftUIView.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/29/24.
//

import SwiftUI

struct SignInView: View {
    @Binding var rqst: Bool
    
    var body: some View {
        ZStack{
            Color.white.opacity(0.08).edgesIgnoringSafeArea([.all])
            VStack{
                Spacer()
                Image("MacroMonkey")
                    .resizable()
                    .frame(width:90*2, height:80*2)
                Spacer()
                Text("Log In or create an account")
                Button(action: {
                    rqst = true
                }, label:{
                    loginBtn
                })
                Spacer()
            }
        }
    }
    
    var loginBtn: some View {
        ZStack{
            Text("Login")
                .font(.largeTitle)
                .padding(6)
                .background(.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    SignInView(rqst: .constant(true))
}
