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
    var foodCache: [Int:Food]=[:]
    var journalCache:[String: Journal]=[:]
    @Published var error: Error?
    @Published var errorMessage: String?
    var journ: Jnl?
    
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

    func fetchFoodInfo(foodID: Int) async throws -> Food {
        if let food = foodCache[foodID]{
            return food
        }
        let querySnapshot = try await db.collection("foods").whereField("id", isEqualTo: foodID).getDocuments()
        
        guard let documentSnapshot = querySnapshot.documents.first else {
            // If no document is found, you could decide to throw an error.
            // For the purpose of this fix, returning an AppUser with empty strings.
            print("No document found with the specified UID")
            return Food.empty
        }
        
        // Using nil-coalescing operator to ensure no property ends up being nil. Defaulting to an empty string if nil.
        let cals = documentSnapshot.get("calories") as? Double ?? 0.0
        let carbs = documentSnapshot.get("carbs") as? Double ?? 0.0
        let fats = documentSnapshot.get("fats") as? Double ?? 0.0
        let id = documentSnapshot.get("id") as? Int ?? 0
        let img = documentSnapshot.get("img") as? String ?? ""
        let name = documentSnapshot.get("name") as? String ?? ""
        let protein = documentSnapshot.get("protein") as? Double ?? 0.0
        let servSize = documentSnapshot.get("servingSize") as? Double ?? 0.0
        let servUnit = documentSnapshot.get("servingUnit") as? String ?? ""
        
        print("Successfully retrieved food:")
        foodCache[foodID] = Food(
            fid: id,
            name: name,
            servSize: servSize,
            servUnit: servUnit,
            cals: cals,
            protein: protein,
            carbs: carbs,
            fats: fats,
            img: img
            )
        return foodCache[foodID]!
    }
    
    func createFood(fd: Food?) -> String {
        var ref: DocumentReference? = nil
        
        if let food = fd {
            // addDocument is one of those “odd” methods.
            ref = db.collection("foods").addDocument(data: [
                "id": food.fid,
                "name": food.name,
                "servingSize": food.servSize,
                "servingUnit": food.servUnit,
                "calories": food.cals,
                "protein": food.protein,
                "carbs": food.carbs,
                "fats": food.fats,
                "img": food.img
            ]) { possibleError in
                if let actualError = possibleError {
                    self.error = actualError
                    print("Write was not successful")
                }
            }
            foodCache[food.fid] = food
        }
        // If we don’t get a ref back, return an empty string to indicate “no ID.”
        return ref?.documentID ?? ""
    }
    
    func fetchJournal(documentId: String) {
          let docRef = db.collection(JOURNAL_COLLECTION_NAME).document(documentId)
          
            docRef.getDocument(as: Jnl.self) { result in
                switch result {
                case .success(let log):
                  // A Book value was successfully initialized from the DocumentSnapshot.
                  self.journ = log
                  self.error = nil
                    
                    // Check if there are entries to process
                    guard let entries = log.entries else {
                        return
                    }

                    // Fetch food details for each entry
                    for entry in entries {
                        self.fetchFood(documentId: entry.altfid) {foodResult in
                            switch foodResult {
                            case .success(let food):
                                // Process each food item as it's loaded
                                // Optionally update a UI element or perform an action
                                print("Successfully retrieved food for entry: \(food.name)")
                            case .failure(let error):
                                print("Error fetching food for entry: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                  // A Book value could not be initialized from the DocumentSnapshot.
                    self.error = error
                    self.errorMessage = "Error decoding document: \(error.localizedDescription)"
                }
              }
            }

    func fetchFood(documentId: String, completion: @escaping (Result<Food, Error>) -> Void) {
        let docRef = db.collection(FOOD_COLLECTION_NAME).document(documentId)
        
        docRef.getDocument(as: Food.self) { result in
            switch result {
            case .success(let food):
                self.foodCache[food.fid] = food
                completion(.success(food))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
