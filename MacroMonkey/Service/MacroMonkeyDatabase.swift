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

    func createFoods(food: Food) -> String {
        var ref: DocumentReference? = nil

        // addDocument is one of those “odd” methods.
        ref = db.collection(COLLECTION_NAME).addDocument(data: [
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

    // Note: This is quite unsophisticated! It only gets the first PAGE_LIMIT articles.
    // In a real app, you implement pagination.
    // TODO: Finish writing the fetchArticles Function (truly a fetch foods function)
    //    func fetchArticles() async throws -> [Food] {
//        let articleQuery = db.collection(COLLECTION_NAME)
//            .order(by: "id", descending: true)
//            .limit(to: PAGE_LIMIT)
//
//        // Fortunately, getDocuments does have an async version.
//        //
//        // Firestore calls query results “snapshots” because they represent a…wait for it…
//        // _snapshot_ of the data at the time that the query was made. (i.e., the content
//        // of the database may change after the query but you won’t see those changes here)
//        let querySnapshot = try await articleQuery.getDocuments()
//
//        return try querySnapshot.documents.map {
//            // This is likely new Swift for you: type conversion is conditional, so they
//            // must be guarded in case they fail.
//            guard let title = $0.get("title") as? String,
//
//                // Firestore returns Swift Dates as its own Timestamp data type.
//                let dateAsTimestamp = $0.get("date") as? Timestamp,
//                let body = $0.get("body") as? String else {
//                throw ArticleServiceError.mismatchedDocumentError
//            }
//
//            return Article(
//                id: $0.documentID,
//                title: title,
//                date: dateAsTimestamp.dateValue(),
//                body: body
//            )
//        }
//    }
}
