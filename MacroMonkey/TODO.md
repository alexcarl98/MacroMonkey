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

Question to ChatGPT:
I want to change the `FoodDetail` below, primarily the `func performSearch(for query: Int)`. It's only querying the API, but I want it to check whether the data has already been cached in the Firestore

make a function in the `Journal` that takes in a food and adds it to the entries list:
```swift
// Journal.swift
import Foundation

struct Journal: Hashable, Codable, Identifiable {
    var id: Int
    var journalDate: Date
    var entryLog = [Entry]()
    func getTotalMacros() -> [Float] {
        var totals: [Float] = [0.0, 0.0, 0.0, 0.0]
        for entry in entryLog {
            totals[0] += entry.calories
            totals[1] += entry.proteins
            totals[2] += entry.carbohydrates
            totals[3] += entry.fats
        }
        return totals
    }
    
    mutating func removeFoodByIndex(_ index: Int) {
        guard index >= 0 && index < entryLog.count else {
            print("Index out of bounds")
            return
        }
        entryLog.remove(at: index)
    }
    
    static let `default` = Journal(
        id: 1001,
        journalDate: Date.now,
        entryLog: [Entry(food: Food.pasta, ratio: 1.2)]
    )
    
    static let `empty` = Journal(
        id: 0,
        journalDate: Date.now
    )
    
}
//
```

```swift
// Entry.
