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
    - I ran into issues during the API app where I had to make the models follow the json data exactly. this kind of bloated my code, since I realistically only needed data that could fit into a single model struct. 
    - How do I get the json data to fall into place in my app? 
