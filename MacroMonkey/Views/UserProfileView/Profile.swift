//
//  Profile.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/15/24.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var mu: MonkeyUser
    
    var body: some View {
        List {
            // User Profile Section
            Section {
                VStack{
                    HStack {
                        Text(mu.profile.initials) // Changed to appUser
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.white, Color(hex: generateColor(from: mu.profile.name)), .black]), startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mu.profile.name) // Changed to appUser
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(mu.profile.email) // Changed to appUser
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                    }
                }
            }
            Text("Age: \(mu.profile.age)")
            Text("Weight (lbs): \(String(format: "%.1f", mu.profile.weight))")
            Text("Height (in): \(String(format: "%.1f", mu.profile.height))")
            Text("Calorie Goal:\n\(String(format: "%.0f", mu.profile.goalCaloricIntake())) until ") + Text(mu.profile.goalDate(), style: .date)
        }
    }
    
    func generateColor(from input: String) -> String {
        let hash = input.hashValue
        let color = String(format: "#%06X", abs(hash) % 0xFFFFFF)
        return color
    }
}

//#Preview {
//    Profile()
//        .environmentObject(MonkeyUser())
//}
