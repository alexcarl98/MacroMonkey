//
//  MacMunkDB.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/30/24.
//


import Foundation
import FirebaseFirestore
import Firebase

// Data structures
struct Jnl: Codable {
    @DocumentID var id: String?
    var date: Date = Date.now
    var entries: [EntryLog]?
    var uid: String
}

struct EntryLog: Codable, Hashable {
    var altfid: String
    var foodID: Int
    var ratio: Double
    var time: Date
}

// Constants
let FOOD_COLLECTION_NAME = "food"
let JOURNAL_COLLECTION_NAME = "journals"
let ENTRY_COLLECTION_NAME = "entryLog"


// Database class for accessing Firestore
class MacMunkDB: ObservableObject {
    private var db = Firestore.firestore()
    var foodCache: [Int:Food]=[:]
    var journal: Jnl?
    
    @Published var error: Error?
    @Published var errorMessage: String? 
    
    func fetchJournal(documentId: String) {
          let docRef = db.collection(JOURNAL_COLLECTION_NAME).document(documentId)
          
            docRef.getDocument(as: Jnl.self) { result in
                switch result {
                case .success(let log):
                  // A Book value was successfully initialized from the DocumentSnapshot.
                  self.journal = log
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
