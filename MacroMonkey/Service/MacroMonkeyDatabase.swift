//
//  MacroMonkeyDatabase.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import Foundation

import Firebase

let COLLECTION_NAME = "food"
let USER_COLLECTION_NAME = "user"
let PAGE_LIMIT = 20

enum ArticleServiceError: Error {
    case mismatchedDocumentError
    case unexpectedError
}

enum FoodServiceError: Error {
    case mismatchedDocumentError
}

class MacroMonkeyDatabase: ObservableObject {
    private let db = Firestore.firestore()
/**

 */
    // Some of the iOS Firebase library’s methods are currently a little…odd.
    // They execute synchronously to return an initial result, but will then
    // attempt to write to the database across the network asynchronously but
    // not in a way that can be checked via try async/await. Instead, a
    // callback function is invoked containing an error _if it happened_.
    // They are almost like functions that return two results, one synchronously
    // and another asynchronously.
    //
    // To deal with this, we have a published variable called `error` which gets
    // set if a callback function comes back with an error. SwiftUI views can
    // access this error and it will update if things change.
    @Published var error: Error?

    func createFood(food: Food) -> String {
        var ref: DocumentReference? = nil

        // addDocument is one of those “odd” methods.
        ref = db.collection("food").addDocument(data: [
            "id": food.id,
            "name": food.name,
            "servSize": food.servSize,
            "servUnit": food.servUnit,
            "calories": food.nutrients.cals,
            "protein": food.nutrients.protein,
            "carbohydrates": food.nutrients.carbs,
            "fats": food.nutrients.fats,
            "imgURL": food.img
        ]) { possibleError in
            if let actualError = possibleError {
                self.error = actualError
            }
        }

        // If we don’t get a ref back, return an empty string to indicate “no ID.”
        return ref?.documentID ?? ""
    }
    
    func createUser(user: AppUser) -> String {
        var ref: DocumentReference? = nil

        // Add user document to the "users" collection
        ref = db.collection("users").addDocument(data: [
            "uid": user.uid,
            "name": user.name,
            "email": user.email,
            "level": user.level,
            "weight": user.weight,
            "height": user.height,
            "dietStartDate": Timestamp(date: user.dietStartDate),
            "dob": Timestamp(date: user.dob),
            "completedCycles": user.completedCycles,
            "goalWeightChange": user.goalWeightChange,
            "sex": user.sex,
            "sexForCalculation": user.sexForCalculation,
            "imgID": user.imgID
        ]) { possibleError in
            if let actualError = possibleError {
                print("Error adding user: \(actualError.localizedDescription)")
            }
        }

        // Return the document ID of the new user entry, or an empty string if no ID is available
        return ref?.documentID ?? ""
    }

    
    func fetchUserProfile(userID: String) async throws -> AppUser {
        let querySnapshot = try await db.collection("users").whereField("uid", isEqualTo: userID).getDocuments()
        
        guard let documentSnapshot = querySnapshot.documents.first else {
            // If no document is found, you could decide to throw an error.
            // For the purpose of this fix, returning an AppUser with empty strings.
            print("No document found with the specified UID")
            return AppUser.default
        }
        
        let documentId = documentSnapshot.documentID
        // Using nil-coalescing operator to ensure no property ends up being nil. Defaulting to an empty string if nil.
        let uid = documentSnapshot.get("uid") as? String ?? ""
        let dietStartDate = (documentSnapshot.get("dietStartDate") as? Timestamp)?.dateValue() ?? Date()
        let dob =  (documentSnapshot.get("dob") as? Timestamp)?.dateValue() ?? Date()
        let name = documentSnapshot.get("name") as? String ?? ""
        let email = documentSnapshot.get("email") as? String ?? ""
        let goalWeightChange = documentSnapshot.get("goalWeightChange") as? Int ?? 0
        let level = documentSnapshot.get("level") as? Int ?? 0
        let completedCycles = documentSnapshot.get("completedCycles") as? Int ?? 0
        let height = documentSnapshot.get("height") as? Float ?? 0.0
        let weight = documentSnapshot.get("weight") as? Float ?? 0.0
        let sex = documentSnapshot.get("sex") as? String ?? ""
        let sexForCalculation = documentSnapshot.get("sexForCalculation") as? String ?? ""
        let imgID = documentSnapshot.get("imgID") as? String ?? ""
        
        print("Successfully retrieved user:")
        return AppUser(
                id: documentId,
                uid: uid,
                name: name,
                email: email,
                level: level,
                weight: weight,
                height: height,
                dietStartDate: dietStartDate,
                dob: dob,
                completedCycles: completedCycles,
                goalWeightChange: goalWeightChange,
                sex: sex,
                sexForCalculation: sexForCalculation,
                imgID: imgID
            )
    }
    
    func userExists(userID: String) async throws -> Bool {
        let querySnapshot = try await db.collection("users").whereField("uid", isEqualTo: userID).getDocuments()
        
        guard let documentSnapshot = querySnapshot.documents.first else {
            // If no document is found, you could decide to throw an error.
            // For the purpose of this fix, returning an AppUser with empty strings.
            print("No document found with the specified UID")
            return false
        }
        return true
    }

    // Note: This is quite unsophisticated! It only gets the first PAGE_LIMIT articles.
    // In a real app, you implement pagination.
    // TODO: Finish writing the fetchArticles Function (truly a fetch foods function)
    func fetchFoods() async throws -> [Food] {
            let foodQuery = db.collection(COLLECTION_NAME)
                .order(by: "id", descending: true)
                .limit(to: PAGE_LIMIT)

            let querySnapshot = try await foodQuery.getDocuments()

            return try querySnapshot.documents.compactMap { document in
                guard let id = document.get("id") as? Int,
                      let name = document.get("name") as? String,
                      let servSize = document.get("servSize") as? Float,
                      let servUnit = document.get("servUnit") as? String,
                      let isFavorite = document.get("isFavorite") as? Bool,
                      let cals = document.get("cals") as? Float,
                      let protein = document.get("protein") as? Float,
                      let carbs = document.get("carbs") as? Float,
                      let fats = document.get("fats") as? Float,
                      let img = document.get("img") as? String else {
                    throw FoodServiceError.mismatchedDocumentError
                }

                return Food(
                    id: id,
                    name: name,
                    servSize: servSize,
                    servUnit: servUnit,
                    isFavorite: isFavorite,
                    nutrients: Nutrient(cals: cals, protein: protein, carbs: carbs, fats: fats),
                    img: img
                )
            }
        }
    
}
