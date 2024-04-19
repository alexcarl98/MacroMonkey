#  Things I need to do

Need to implement the below code:
```swift
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
```
## Database Design: 
    - hone in on the design of your database, will you:
        - cache food data to the firestore database OR
        - Store only  


## API Calls:
- We now have the API Working, but now we need to implement the added details

---

# Notes

## API calls to query by nutrition ID: 
https://spoonacular.com/food-api/docs#Nutrition-by-ID 

GET `https://api.spoonacular.com/recipes/`{id}`/nutritionWidget.json`
