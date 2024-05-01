//
//  MacroMonkeyDatabase.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/13/24.
//

import Foundation

import Firebase


import Foundation
import FirebaseFirestore

// Data structures
//struct Jnl: Codable {
//    @DocumentID var id: String?
//    var date: Date = Date.now
//    var entries: [EntryLog]?
//    var uid: String
//}
//
//struct EntryLog: Codable, Hashable {
//    var foodID: Int
//    var ratio: Double
//    var time: Date
//}

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
        let initJournalString = createNewJournalForUser(userID: user.uid)
        
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
            "journals": [initJournalString],
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
        guard let documentSnapshot = querySnapshot.documents.first else {
            // If no document is found, you could decide to throw an error.
            // For the purpose of this fix, returning an AppUser with empty strings.
            print("No document found with the specified UID")
            return false
        }
        return true
    }
    
    func createNewJournalForUser(userID: String) async throws -> String {
        var ref: DocumentReference? = nil
        
        ref = db.collection(JOURNAL_COLLECTION_NAME).addDocument(data:[
            "date": Timestamp(date: Date.now),
            "uid": userID,
            "entries": [Entry]()
        ])
        let journalStr = ref?.documentID ?? ""
        
        let userRef = db.collection("users")
        do{
            let querySnapshot = try await userRef.whereField("uid", isEqualTo: userID).getDocuments()
            for document in querySnapshot.documents{
                try await document?.updateData(["journals": FieldValue.arrayUnion([journalStr])])
            }
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
        
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
            //
            try await docRef.updateData(["entries": FieldValue.arrayUnion([entry])])
            print("Updated entries for Journal \(documentId) successfully")
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
    }

}
