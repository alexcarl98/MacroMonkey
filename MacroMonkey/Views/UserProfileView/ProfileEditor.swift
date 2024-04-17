//
//  ProfileEditor.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/16/24.
//

import SwiftUI

struct ProfileEditor: View {
    @Binding var newUser: AppUser
    
    let activityLevelDesc = ["", "Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extremely Active"]
    let sexes = ["Male", "Female", "Other"]
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Date()
        return min...max
    }
    
    var body: some View {
        List {
            HStack {
                Text("Username")
                Spacer()
                TextField("Username", text: $newUser.name)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Weight (lbs)")
                Spacer()
                TextField("Weight", value: $newUser.weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Height (inches)")
                Spacer()
                TextField("Height", value: $newUser.height, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Goal Change in lb:")
                Spacer()
                TextField("Goal lb", value: $newUser.goalWeightChange, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            DatePicker("Date of Birth", selection: $newUser.dob, in: dateRange, displayedComponents: .date)
            
            Picker("Activity Level", selection: $newUser.level) {
                ForEach(1...5, id: \.self) { level in
                    Text("\(activityLevelDesc[level])").tag(level)
                }
            }
            
            Picker("Sex", selection: $newUser.sex) {
                // TODO: Need to fix this
                ForEach(sexes, id: \.self) { sex in
                    Text(sex)
                }
            }

            Picker("Sex (calculations)", selection: $newUser.sexForCalculation) {
                // TODO: Need to fix this
                ForEach(sexes, id: \.self) { sex in
                    Text(sex)
                }
            }
            HStack {
                Text("Calculated Calorie Goal")
                Spacer()
                Text(String(format: "%.0f", (newUser.goalCaloricIntake())))
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    ProfileEditor(newUser: .constant(AppUser.default))
}
