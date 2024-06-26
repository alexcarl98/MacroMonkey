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
    var imgID: String
    var journalIDs = [String]()
    
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
    
    var daysToDiet: Int {
        let v = Calendar.current.dateComponents([.day], from: dietStartDate, to: Date()).day ?? 0
        return 66 - v
    }
    
    var heightString: String{
        let ft = Int(self.height) % 12
        let inch = self.height - (Float(ft) * 12.0)
        return "\(ft)' \(String(format: "%.0f", inch))\""
    }
    
    func idw() -> Float {
        // Calculation for ideal weight dependent on height
        // TODO: add an if statement for `if sex == "Female"{}
        let lb_kg_convert = 2.20462
        let height_over_five = height - 60.0
        if (height < 60){
            return Float(52.0 * lb_kg_convert)
        }
        return Float((52.0 + (1.9*Double(height_over_five)))*lb_kg_convert)
    }
    
    func bmr() -> Float {
        // Calculation for Basal Metabolic Rate [# of calories to eat to stay at current weight]
        if sex == "Male" {
            return (88.362 + (6.08 * weight) + (12.19 * height) - (5.677 * Float(age)))*activityLvlMultiplier[level]
        }
        return (444.592 + (4.19 * weight) + (7.87 * height) - (4.33 * Float(age)))*activityLvlMultiplier[level]
    }
    
    func goalDate() -> Date{
        //
        
        return Calendar.current.date(byAdding: .day, value: daysToDiet, to: Date())!
    }
    
    func goalCaloricIntake() -> Float {
        // Goal Caloric intake, dependent on: Current weight relative to ideal weight, Base metabolic rate, and the goal amount to lose or gain after diet period
        var dif: Float = Float(goalWeightChange)
        let calPerLb:Float = 3500.0
        if (weight > idw()){ dif = dif * (-1.0) }
        let dailyDif = Float(dif*calPerLb) / Float(daysToDiet)
        let BemR = bmr()
        return (BemR + dailyDif)
    }
    
    func goalMacros() -> [Float]{
            // An estimate for the amount of daily calories, proteins, carbs, and fats someone needs
            let goalCal = goalCaloricIntake()
            return [goalCal, goalCal*0.0404, goalCal*0.1374, goalCal*0.027667]
        }

    
    static let `default` = AppUser (
        id: "12345",
        uid: "rxKNDDdD8HPi9pLUHtbOu3F178J3",
        name: "John Hanz",
        email: "jghanz1987@gmail.com",
        level: 2,
        weight: 170,
        height: 65,
        dietStartDate: Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 1))!,
        dob: Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!,
        completedCycles: 1,
        goalWeightChange: -2,
        sex: "Male",
        imgID: ""
    )
    
    static let `empty` = AppUser(
        id: "",
        uid: "",
        name: "",
        email: "",
        level: 0,
        weight: 0,
        height: 0,
        dietStartDate: Date.now,
        dob: Date.now,
        completedCycles: 0,
        goalWeightChange: 0,
        sex: "Female",
        imgID: ""
    )
}
