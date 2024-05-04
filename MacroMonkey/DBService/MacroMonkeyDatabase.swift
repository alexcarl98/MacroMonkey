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
        let journalIDs = documentSnapshot.get("journals") as? [String] ?? [String]()
        
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
    
    func createNewJournalForUser(userID: String, aid: String) -> Journal {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        let jd = formatter.string(from: Date.now)
        let newJournal = Journal(uid: userID, journalDate: jd)
        var ref: DocumentReference? = nil
        ref = db.collection("journals").addDocument(data: [
            "uid": newJournal.uid,
            "journalDate": newJournal.journalDate,
            "entryLog": newJournal.entryLog.map { ["food": $0.food, "ratio": $0.ratio] }
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                // Append the new document ID to an array in a separate collection
                self.db.collection("users").document(aid).updateData([
                    "journals": FieldValue.arrayUnion([ref!.documentID])
                ])
            }
        }
        return newJournal
    }
    
    
    func fetchManyJournals(uid: String) async throws -> [Journal] {
        var journals = [Journal]()
        let journalRef = db.collection(JOURNAL_COLLECTION_NAME)
        do {
            let querySnapshot = try await journalRef.whereField("uid", isEqualTo: uid).getDocuments()
            for document in querySnapshot.documents {
                print(document)
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
    
    func addJournalInstanceToUser(uid: String, journalId: String) async throws {
        let querySnapshot = try await db.collection("users").whereField("uid", isEqualTo: uid).getDocuments()
        let docRef = querySnapshot.documents.first!.reference

        do {
            // Update the 'journals' field by appending 'journalId' to the existing array
            try await docRef.updateData(["journals": FieldValue.arrayUnion([journalId])])
            print("Updated entries for Journal \(journalId) successfully")
        } catch {
            print("ERROR: \(error.localizedDescription)")
            throw error
        }
    }
    
//    func addJournalEntries(documentId: String, entry: Entry) async throws {
//        let docRef = db.collection(JOURNAL_COLLECTION_NAME).document(documentId)
//        do {
//            // want to create a new map:
//            try await docRef.updateData(["entries": [entry]] )
//            print("Updated entries for Journal \(documentId) successfully")
//        } catch {
//            print("ERROR: \(error.localizedDescription)")
//            throw error
//        }
//    
//    }
    
//    func writeEntToFB(docID:String, entry: Entry) -> String? {
//        let collectionRef = db.collection("entries")
//        do{
//            let newDocReference = try collectionRef.addDocument(from: entry)
//            return newDocReference.documentID
//        } catch {
//            print(error)
//        }
//        return nil
//    }
//    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    ///
    ///
    
    
    
    func updateEntries(journalID: String, entries: [Entry]) async throws {
        var ref: DocumentReference? = nil
        ref = db.collection("journals").document(journalID)
        
        do {
            if let journalRef = ref {
                let entryDictionaries = entries.map { $0.toDictionary() }
                try await journalRef.updateData(["entryLog": entryDictionaries])
            }
            print("Check out firestore")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func addEntryToJournal(journalID: String, ent: Entry) async throws -> Entry {
    //    func addEntryToJournal() async throws -> Entry? {
            var ref: DocumentReference? = nil
    //        let journalID = "3BExlSZiBOdQ6xbLMgbl"
//            let journalDate = "05-02-24"
    //        let userID = "GEb6bKEuz3cBsSNPuz2Giv2QCvh2"
    //        let ent = Entry(food: 123, ratio:1.1)
            ref = db.collection("journals").document(journalID)
            
            do {
                let entry: [String: Any] = ["food": ent.food, "ratio": ent.ratio, "time": ent.time]
                if let journalRef = ref {
                    try await journalRef.updateData(["entryLog": FieldValue.arrayUnion([entry])])
                }
                
                print("check out firestore")
                

            } catch{
                print("Error: \(error.localizedDescription)")
            }
            
            return Entry.default
        }
    
    
    func getJournal(withId userID: String, on journalDate: String) async throws -> Journal {
//        let userID = "GEb6bKEuz3cBsSNPuz2Giv2QCvh2"
//        let journalDate = "05-02-24"
        let querySnapshot = try await db.collection("journals").whereField("uid", isEqualTo: userID).whereField("journalDate", isEqualTo: journalDate).getDocuments()
        var entries = [Entry]()
        guard let journ = querySnapshot.documents.first else {
            // If no document is found, you could decide to throw an error.
            // For the purpose of this fix, returning an AppUser with empty strings.
            print("No document found with the specified UID")
            return Journal.empty
        }
        var journal: Journal?
        do {
            // DISPLAYING NON-OPTIONAL JOURNAL INFO
//            print(querySnapshot)
            let jid = journ.documentID
            let uid = journ.get("uid") as? String ?? ""
            let journalDat = journ.get("journalDate") as? String ?? ""
            print(jid)
            print(uid)
            print(journalDat)
            journal = Journal(id: jid, uid: uid, journalDate: journalDat, entryLog:[])
        } catch{
            print("Error: \(error.localizedDescription)")
        }
        do {
            // DISPLAYING OPTIONAL JOURNAL INFO
            let entryLog = journ.get("entryLog") as? [[String: Any]] ?? [["food": -1, "ratio": 0.0]]
            for entry in entryLog{
                let food = entry["food"] as? Int ?? -1
                let ratio = entry["ratio"] as? Double ?? 0.0
                let tm = (entry["time"] as? Timestamp)?.dateValue() ?? Date()
                if food != -1 {
                    entries.append(Entry(
                        food: food ,
                        ratio: ratio ,
                        time: tm)
                    )
                }
                if let entry = entries.last{
                    entry.printNicely()
                }
            }
            journal?.entryLog = entries
            
            
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        return journal ?? Journal.empty
    }
    
    func getJournalsBelongingto(withUserID userID: String) async throws -> [Journal] {
      var journals = [Journal]()
      let querySnapshot = try await db.collection("journals").whereField("uid", isEqualTo: userID).getDocuments()
      for document in querySnapshot.documents {
        let journal: Journal
        do {
          let jid = document.documentID
          let uid = document.get("uid") as? String ?? ""
          let journalDate = document.get("journalDate") as? String ?? ""
          let entryLog = document.get("entryLog") as? [[String: Any]] ?? [["food": -1, "ratio": 0.0]]
          
          var entries = [Entry]()
          for entry in entryLog {
            let food = entry["food"] as? Int ?? -1
            let ratio = entry["ratio"] as? Double ?? 0.0
            let tm = (entry["time"] as? Timestamp)?.dateValue() ?? Date()
            if food != -1 {
              entries.append(Entry(food: food, ratio: ratio, time: tm))
            }
          }
          journal = Journal(id: jid, uid: uid, journalDate: journalDate, entryLog: entries)
        } catch {
          print("Error creating journal: \(error.localizedDescription)")
          continue
        }
        journals.append(journal)
      }
      return journals
    }
}
