//
//  MacroMonkeyDatabase.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import Foundation
import Firebase
import FirebaseFirestore


//let FOOD_COLLECTION_NAME = "foods"
let FOOD_COLLECTION_NAME = "foods"
let USER_COLLECTION_NAME = "user"
let JOURNAL_COLLECTION_NAME = "journals"
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
    
//    var journalCache:[String: Journal]=[:]
    @Published var error: Error?
    @Published var errorMessage: String?
    var journ: Journal?
    
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
            "journals": [String](),
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
        var journalIDs = documentSnapshot.get("journals") as? [String] ?? [String]()
        
        if journalIDs.count == 0 {
            let str = createNewJournalForUser(userID: uid)
            journalIDs.append(str)
        }
        
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
                imgID: imgID,
                journalIDs: journalIDs
            )
    }
    
    
    func userExists(userID: String) async throws -> Bool {
        let querySnapshot = try await db.collection("users").whereField("uid", isEqualTo: userID).getDocuments()
        return querySnapshot.documents.first != nil
    }
    
    func createNewJournalForUser(userID: String) -> String {
        var ref: DocumentReference? = nil
        
        ref = db.collection(JOURNAL_COLLECTION_NAME).addDocument(data:[
            "date": Timestamp(date: Date.now),
            "uid": userID,
            "entries": [String]()
        ])
        let journalStr = ref?.documentID ?? ""
        return journalStr
    }
    
    func fetchManyJournals(uid: String) async throws -> [Journal] {
        var journals = [Journal]()
        let journalRef = db.collection(JOURNAL_COLLECTION_NAME)
        do {
            let querySnapshot = try await journalRef.whereField("uid", isEqualTo: uid).getDocuments()
            for document in querySnapshot.documents {
                // Journal object is encodable and decodable. how do I get this as a list and then return
                if let journalData = try? document.data(as: Journal.self) {
                    journals.append(journalData)
                }
            }
        } catch{
            print("Error getting documents: \(error.localizedDescription)")
        }
        return journals
    }
    
    func fetchJournal(documentId: String) async throws -> Journal {
        let docRef = db.collection(JOURNAL_COLLECTION_NAME).document(documentId)
        do {
            let journal: Journal = try await docRef.getDocument(as: Journal.self)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional, for more readable output
            if let jsonData = try? encoder.encode(journal) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)  // Printing the JSON string
                }
            }
            print("Fetched Journal \(documentId) successfully")
            return journal
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
    }
    
    func addJournalEntries(documentId: String, entry: Entry) async throws {
        let docRef = db.collection(JOURNAL_COLLECTION_NAME).document(documentId)
        do {
            // want to create a new map:
            try await docRef.updateData(["entries": [entry]] )
            print("Updated entries for Journal \(documentId) successfully")
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
    }
    
    func writeEntToFB(docID:String, entry: Entry) -> String? {
        let collectionRef = db.collection("entries")
        do{
            let newDocReference = try collectionRef.addDocument(from: entry)
            return newDocReference.documentID
        } catch {
            print(error)
        }
        return nil
    }
    
    
//    
//    func writeJournalEntries(journalRef: DocumentReference, entries: [Entry]) async throws {
//        // TODO: Get to also read and write from the cache
//        // Fetch all current entries in the journal's 'entryLog' subcollection
//        let currentEntriesSnapshot = try await journalRef.collection("entryLog").getDocuments()
//        var currentEntries = [String: DocumentSnapshot]()  // Dictionary to map time and foodId to document snapshot
//
//        // Populate the dictionary with existing entries
//        for document in currentEntriesSnapshot.documents {
//            let time = (document.get("time") as? Timestamp)?.dateValue() ?? Date()
//            let foodId = document.get("foodId") as? Int ?? 0
//            let key = "\(foodId)_\(time.timeIntervalSince1970)"
//            currentEntries[key] = document
//        }
//
//        // Iterate over new entries to add or update
//        for entry in entries {
//            let key = "\(entry.food.id)_\(entry.time.timeIntervalSince1970)"
//            if let existingDocument = currentEntries[key] {
//                // Check if ratio has changed; if so, update
//                if existingDocument.get("ratio") as? Float != entry.ratio {
//                    let updateData: [String: Any] = [
//                        "ratio": entry.ratio,
//                        "foodId": entry.food.id,
//                        "time": Timestamp(date: entry.time)
//                    ]
//                    try await existingDocument.reference.updateData(updateData)
//                }
//            } else {
//                // If the entry doesn't exist, add it
//                let newData: [String: Any] = [
//                    "foodId": entry.food.id,
//                    "ratio": entry.ratio,
//                    "time": Timestamp(date: entry.time)
//                ]
//                let _ = journalRef.collection("entryLog").addDocument(data: newData)
//            }
//            // Remove the processed entry from the dictionary to track entries that are no longer present
//            currentEntries.removeValue(forKey: key)
//        }
//        // Any remaining entries in the dictionary are not in the new entries list and should be deleted
//        for (_, document) in currentEntries {
//            try await document.reference.delete()
//        }
//    }


}
