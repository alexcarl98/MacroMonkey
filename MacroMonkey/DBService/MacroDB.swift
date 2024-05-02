//
//  MacroDB.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 5/2/24.
//

import Foundation
import Firebase
import FirebaseFirestore


//let FOOD_COLLECTION_NAME = "foods"
let U_COLLECTION = "user"
let D_COLLECTION = "dailyintake"


class MacroDB: ObservableObject {
    struct DailyIntake {
            var userId: String
            var date: String
            var entries = [FoodEntry]()
        }

    struct FoodEntry {
        let foodId: Int
        var servingSize: Double
        let mealType: String
        let timestamp: Date
    }
    
    private let db = Firestore.firestore()
    
    func pretendWriteTodaysIntake() {
        let userId = "rxKNDDdD8HPi9pLUHtbOu3F178J3"
        let date = "2024-05-03"
        let foodEntries = [
            ["foodId": "food456", "servingSize": 1, "mealType": "breakfast", "timestamp": "08:00"],
            ["foodId": "food789", "servingSize": 2, "mealType": "lunch", "timestamp": "12:30"]
        ]
        
        let data: [String: Any] = [
            "userId": userId,
            "date": date,
            "foodEntries": foodEntries
        ]
        
        db.collection("Daily Intake")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isEqualTo: date)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let foodEntries = document.data()["foodEntries"] as? [[String: Any]] ?? []
                        for entry in foodEntries {
                            let foodId = entry["foodId"] as? Int ?? 0
                            let servingSize = entry["servingSize"] as? Int ?? 0
                            let mealType = entry["mealType"] as? String ?? ""
                            let timestamp = (entry["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                            
                            // Fetch food details from API using foodId
                            // Use fetched data to populate your UI or perform calculations
                        }
                    }
                }
            }
    }
    
    func pretendReadTodaysIntake(userId:String, date:String) async throws -> DailyIntake {
        var thisIntake: DailyIntake = DailyIntake(userId: userId, date: date)
        let foodEntries = [
            ["foodId": "food456", "servingSize": 1, "mealType": "breakfast", "timestamp": "08:00"],
            ["foodId": "food789", "servingSize": 2, "mealType": "lunch", "timestamp": "12:30"]
        ]
        
        do{
            let snapshot = try await db.collection("dailyintake").whereField("userId", isEqualTo: userId).whereField("date", isEqualTo: date).getDocuments()
            
            for document in snapshot.documents{
                var foodEntries = document.data()["foodEntries"] as? [[String: Any]] ?? []
                for entry in foodEntries {
                    let foodId = entry["foodId"] as? Int ?? 0
                    let servingSize = entry["servingSize"] as? Double ?? 0
                    let mealType = entry["mealType"] as? String ?? ""
                    let timestamp = (entry["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Fetch food details from API using foodId
                    // Use fetched data to populate your UI or perform calculations
                    thisIntake.entries.append(FoodEntry(foodId: foodId, servingSize: servingSize, mealType: mealType, timestamp: timestamp))
                    
                }
            }
        } catch {
            print(error)
        }
        
        return thisIntake
    }
}

    
    
    

