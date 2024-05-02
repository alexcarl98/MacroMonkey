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
        let servSize = documentSnapshot.get("servingSize") as? Float ?? 0.0
        let servUnit = documentSnapshot.get("servingUnit") as? String ?? ""
        
        print("Successfully retrieved food:")
        foodCache[foodID] = Food(
            id: id,
            name: name,
            servSize: servSize,
            servUnit: servUnit,
            cals: Float(cals),
            protein: Float(protein),
            carbs: Float(carbs),
            fats: Float(fats),
            img: img
            )
        
        return foodCache[foodID]!
    }
    
    func createFood(fd: Food?) -> String {
        var ref: DocumentReference? = nil
        
        if let food = fd {
            // addDocument is one of those “odd” methods.
            ref = db.collection("foods").addDocument(data: [
                "id": food.id,
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
            foodCache[food.id] = food
        }
        // If we don’t get a ref back, return an empty string to indicate “no ID.”
        return ref?.documentID ?? ""
    }

    func writeFBEntry(journalID: String, en: FBEntry?) -> String {
        var ref: DocumentReference? = nil
        
        if let entry = en {
            // addDocument is one of those “odd” methods.
            ref = db.collection("foods").addDocument(data: [
                "date": Timestamp(date: entry.time),
                "foodID": entry.foodID,
                "jid": journalID,
                "ratio": entry.ratio
            ]) { possibleError in
                if let actualError = possibleError {
                    self.error = actualError
                    print("Write was not successful")
                }
            }
        }
        // If we don’t get a ref back, return an empty string to indicate “no ID.”
        return ref?.documentID ?? ""
    }
    
    func fetchJournalEntries(journalID: String) async throws -> [FBEntry] {
        let querySnapshot = try await db.collection("entryLog").whereField("jid", isEqualTo: journalID).getDocuments()
        
        return try querySnapshot.documents.map {
            // This is likely new Swift for you: type conversion is conditional, so they
            // must be guarded in case they fail.
            guard let jid = $0.get("jid") as? String,
                let dateAsTimestamp = $0.get("date") as? Timestamp,
                let ratio = $0.get("ratio") as? Double,
                let foodID = $0.get("foodID") as? Int else {
                throw ArticleServiceError.mismatchedDocumentError
            }
            return FBEntry(
                jid: jid,
                foodID: foodID,
                ratio: Float(ratio),
                time: dateAsTimestamp.dateValue(),
                id: $0.documentID
            )
        }
    }
    
    func fetchJournal(by uid: String) async throws -> Journal {
        // TODO: Know this
        let journalDateString = formatDate(date: Date.now)
//        let journalTimestamp = journalDate.timeIntervalSince1970
        
        // Check cache first
        if let cachedJournal = journalCache[journalDateString] {
            return cachedJournal
        }

        // Query Firestore for the journal
        let journalQuery = db.collection("journals").whereField("uid", isEqualTo: uid)
            

        let querySnapshot = try await journalQuery.getDocuments()

        guard let document = querySnapshot.documents.first else {
            throw ArticleServiceError.mismatchedDocumentError // Using a relevant error
        }

        let journalID = document.documentID
        let fetchedJournalDate = (document.get("journalDate") as? Timestamp)?.dateValue() ?? Date()
//        let entries = try await fetchJournalEntries(journalID: jid)
        
        var journal = Journal(id: journalID, journalDate: fetchedJournalDate, uid: uid, entryLog: [])
        journal.entryLog = try await fetchJournalEntries(journalID: journalID)
        journalCache[journalDateString] = journal  // Cache the fetched journal

        return journal
    }
    
    func writeJournalEntries(journalID: String, entries: [FBEntry]) async throws -> String {
        // TODO: Get to also read and write from the cache
        // Fetch all current entries in the journal's 'entryLog' subcollection
        let currentEntriesSnapshot = try await db.collection("entryLog").whereField("jid", isEqualTo: journalID).getDocuments()
        var currentEntries = [String: DocumentSnapshot]()  // Dictionary to map time and foodId to document snapshot

        // Populate the dictionary with existing entries
        for document in currentEntriesSnapshot.documents {
            let time = (document.get("time") as? Timestamp)?.dateValue() ?? Date()
            let foodId = document.get("foodId") as? Int ?? 0
            let key = "\(foodId)_\(time.timeIntervalSince1970)"
            currentEntries[key] = document
        }

        // Iterate over new entries to add or update
        for entry in entries {
            let key = "\(entry.foodID)_\(entry.time)"
            if let existingDocument = currentEntries[key] {
                // Check if ratio has changed; if so, update
                if existingDocument.get("ratio") as? Float != entry.ratio {
                    let updateData: [String: Any] = [
                        "ratio": entry.ratio
                    ]
                    try await existingDocument.reference.updateData(updateData)
                }
            } else {
                // If the entry doesn't exist, add it
                let newData: [String: Any] = [
                    "foodId": entry.foodID,
                    "ratio": entry.ratio,
                    "time": Timestamp(date: entry.time)
                ]
                let _ = try await db.collection("entryLog").addDocument(data: newData)
            }
            // Remove the processed entry from the dictionary to track entries that are no longer present
            currentEntries.removeValue(forKey: key)
        }
        // Any remaining entries in the dictionary are not in the new entries list and should be deleted
        for (_, document) in currentEntries {
            try await document.reference.delete()
        }
        return ""
    }
    
    func fetchEntries(journalID: String) async throws -> [FBEntry] {
        let querySnapshot = try await db.collection("entryLog").whereField("jid", isEqualTo: journalID).getDocuments()
        
        return try querySnapshot.documents.map {
            // This is likely new Swift for you: type conversion is conditional, so they
            // must be guarded in case they fail.
            guard let jid = $0.get("jid") as? String,
                let dateAsTimestamp = $0.get("date") as? Timestamp,
                let ratio = $0.get("ratio") as? Double,
                let foodID = $0.get("foodID") as? Int else {
                throw ArticleServiceError.mismatchedDocumentError
            }
            return FBEntry(
                jid: jid,
                foodID: foodID,
                ratio: Float(ratio),
                time: dateAsTimestamp.dateValue(),
                id: $0.documentID
            )
        }
        
    }

    
    
    func writeJournal(journal: Journal, uid: String) async throws -> String{
        let journalDateString = formatDate(date: journal.journalDate)
        // JournalDateString formatted
        let journalTimeStamp = journal.journalDate.timeIntervalSince1970
        
        var ref: DocumentReference? = nil
        
        if journalCache[journalDateString] == nil {
            do {
                ref = try await db.collection("journals").addDocument(data: ["uid": uid, "journalDate": journalDateString])
                if ref != nil {
                    journalCache[journalDateString] = Journal(id: ref!.documentID, journalDate: journal.journalDate, uid: uid)
                }
            }catch {
                throw error
            }
        }
        return ref?.documentID ?? ""
    }
}
