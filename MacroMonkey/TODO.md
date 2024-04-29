#  Things I need to do
1. Create some firebase data that matches the below collection design. Get your app to talk to Firebase to fetch and query that data
2. Determine whether you want to buy the API Shit or the Firebase shit, which is more costly...
3. `FoodDetail.swift`:
    a. Add a boolean value: `@State var loadFromFirebase: Bool = false`. This will allow us to instead fetch food info from firebase rather than always calling the API
    b. Implement an *Add* Button. When the user clicks on Add, it not only records this food data locally and displays on the home page (macro graph view), but will also record the food data to firebase.
4. `MacroMonkeyDatabase.swift`:
    a. add in all the 'read' and 'write' functions for your new model data.
5. `ProfileSetup.swift`:
    a. TODO: After the user signs in for the first time, a pop-up reveals itself and the user needs to put in the rest of their information in these fields. The problem is that this sheet is dismissible by swiping down. This is bad since it will not write complete data for a user to firebase.  



# Notes
## API calls to query by nutrition ID: 
https://spoonacular.com/food-api/docs#Nutrition-by-ID 

GET `https://api.spoonacular.com/recipes/`{id}`/nutritionWidget.json`




# Database Design: 
> It's beginning to dawn on me just how hairy this is going to get. Our users are going to have a lot of variable data, so we want to avoid as much redundancy as possible,  
Alright so First I'm going to list off all the data that I have and need to use

About these notes: while all collections will have an id for each elements, when I explicitly state **id**, that means that there will be functionality that is dependent on the string ID of that collection


## Collection: `users`
users:
    ↳ uid : String
    ↳ dietStartDate : Date
    ↳ dob : Date
    ↳ name : String
    ↳ email : String
    ↳ level : Int
    ↳ completedCycles : Int
    ↳ goalWeightChange: Int
    ↳ height: Float
    ↳ weight: Float
    ↳ sex: String
    ↳ imgID: String
    ↳ journals: Map(Date: String)

### NOTE:
Journals will likely be a map, mapping dates to their id strings of the corresponding journal


## Collection: `journals`
journals
    ↳ **id**
    ↳ entries: [entry]


## Collection: `entry`
entry
    ↳ **id**
    ↳ foodID: String
    ↳ ratio: Float
    ↳ time: Date


## Collection: foods:
food
    ↳ foodID (*issued by Spoonacular*)
    ↳ name
    ↳ servSize
    ↳ servUnit
    ↳ calories
    ↳ protein
    ↳ carbs
    ↳ fats
    ↳ imgURL


Journal Logic:

I need help with Firebase Firestore reading and writing functions in my swift app
Within firestore, we have a collection: `journals` containing:
- A subcollection called `entryLog` containing:
    - `foodId`: Number value corresponding with foodID (this corresponds to a separate collection)
    - `ratio`: The amount of that food eaten at that time
    - `time`: The time it was documented
- `journalDate`: time stamp of the journal's date
- `uid`: String for user id corresponding to this specific journal
The foodId corresponds to another collection, `foods`. I already have a fetch function for getting these foods by the corresponding `foodID`

write a swift function that can read and write data to the firestore collection given the following Swift structs:
```swift
import Foundation

struct Journal: Hashable, Codable, Identifiable {
    var id: String
    var journalDate: Date
    var entryLog = [Entry]()
}

struct Entry: Hashable, Codable {
    //would need to use the existing function: fetchFoodInfo(food: Int) to get this Food object as the entryLog only has the foodID string
    var food: Food  
    var ratio: Float
    var time: Date = Date.now
}
struct Food: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var servSize: Float
    var servUnit: String
    var cals: Float
    var protein: Float
    var carbs: Float
    var fats: Float
    var img: String
}
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
}

```


Logic Within `Home.swift`
if `mu.journal.entryLog`.size > 0 {
    // i.e. if a food is added for the current date:
    
}

157106
716429

```swift
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
}

```
