//
//  AppUser.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import Foundation

struct AppUser: Hashable, Codable, Identifiable {
    var id: String
    var uid: String
    var name: String
    var email: String
    var level: Int
    var weight: Float
    var height: Float
    var dietStartDate: Date
    var dob: Date
    var completedCycles: Int
    var goalWeightChange: Int
    var sex: String
    var sexForCalculation: String
    var imgID: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    var activityLvlMultiplier:[Float] = [1, 1.2, 1.375, 1.55, 1.725, 1.9]
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: dob, to: Date()).year ?? 0
    }
    
    func bmr() -> Float {
        // Calculation for Basal Metabolic Rate [# of calories to eat to stay at current weight]
        return ((6.23762 * weight) + (12.7084 * height) - (6.755 * Float(age)))*activityLvlMultiplier[level]
    }
    
//    func goalDate() -> Date{
//        //
//        return Calendar.current.date(byAdding: .day, value: daysToDiet, to: Date())!
//    }

    static let `default` = AppUser(
        id: "12345",
        uid: "91JqW2pm3DZioPnC1dW9Bv8JYf02",
        name: "John Hanz",
        email: "jghanz1987@gmail.com",
        level: 2,
        weight: 170,
        height: 65,
        dietStartDate: Date.now,
        dob: Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!,
        completedCycles: 1,
        goalWeightChange: -2,
        sex: "Male",
        sexForCalculation: "Male",
        imgID: ""
    )
}
