import SwiftUI

let CALORIES_COLOR = Color(hex: "#702963")
let PROTEIN_COLOR = Color(hex: "#009688")
let FATS_COLOR = Color(hex: "#E97120")
let CARBS_COLOR = Color(hex:"#4169E1")

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yy"
    return formatter.string(from: date)
}

struct ContentView: View {
    @EnvironmentObject var auth: MacroMonkeyAuth
    @EnvironmentObject var firebaseServices: MacroMonkeyDatabase
    @EnvironmentObject var spoonacularService: SpoonacularService
    @EnvironmentObject var mu: MonkeyUser  // Initialize with default or empty values
    @State var requestLogin: Bool = false
    @State var loggedIn: Bool = false
    @State var isNewUser: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
            if loggedIn && !isLoading {
                if isNewUser {
                    ProfileSetup(newUser: $mu.profile, newJournal: $mu.journal, editing: $isNewUser)
                    //                        .onDisappear{
                    //                            handleUserAuthentication()
                    //                        }
                    
                } else {
                    mainTabView
                }
            } else if isLoading {
                ProgressView("Signing In…")
            } else {
                SignInFlow()
            }
        }
    
    var mainTabView: some View {
        TabView {
            FoodJournalList(requestLogin: $requestLogin, loggedIn: $loggedIn)
                .environmentObject(mu)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            PlanProgressView()
                .environmentObject(mu)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
            Profile()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }

    @ViewBuilder
    private func SignInFlow() -> some View {
        if let authUI = auth.authUI {
            SignInView(rqst: $requestLogin)
                .sheet(isPresented: $requestLogin) {
                    ZStack {
                        AuthenticationViewController(authUI: authUI)
                            .onDisappear {
//                                mu.objectWillChange.send()
                                handleUserAuthentication()
                            }
                    }
                }
        } else {
            ErrorView()
        }
    }

    @ViewBuilder
    private func ErrorView() -> some View {
        VStack {
            Text("Sorry, looks like we aren’t set up right!")
                .padding()
            Text("Please contact this app’s developer for assistance.")
                .padding()
        }
    }
    
    private func handleUserAuthentication() {
        isLoading = true
        Task {
            do {
                if auth.userID != "" {
                    loggedIn = true

                    let userExists = try await firebaseServices.userExists(userID: auth.userID)
                    
                    if userExists {
                        let updatedUser = await fetchUserInformation(uid: auth.userID)
//                         Update existing mu properties
                        mu.profile = updatedUser.profile
                        mu.journals = updatedUser.journals
                        mu.foodCache = updatedUser.foodCache
                        mu.journal = updatedUser.journals.last ?? Journal.empty
                    } else {
                        mu.profile = AppUser.empty
                        mu.profile.uid = auth.userID
                        mu.profile.email = auth.userEmail
                        mu.profile.name = auth.userName
                        isNewUser = true
                    }
                    print("User: \(mu.profile.name)")
                    isLoading = false
                }
            } catch {
                print("Error during user authentication: \(error)")
                isLoading = false
            }
        }
    }
    
   
    
    
    func fetchUserInformation(uid: String) async -> MonkeyUser {
        do {
            // Fetch user profile
            let user = try await firebaseServices.fetchUserProfile(userID: uid)
            
            var journals = try await firebaseServices.getJournalsBelongingto(withUserID: uid)
            
            for j in journals {
                j.printNicely()
            }
            
            var foods:[Food] = [Food]()
            var foodCache: [Int: Food] = [:] // Initialize an empty food cache
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yy"
            let journalDat = formatter.string(from: Date.now)
            
            
            if let todayJournal = journals.first(where: { $0.journalDate == journalDat }){
                // if there's already a journal, get it
                if todayJournal.entryLog.count != 0 {
                    foods = await spoonacularService.performBulkSearch(for: todayJournal.getEntriesInBulk()) ?? [Food]()
                    // Populate the foodCache map
                    for food in foods {
                        foodCache[food.id] = food
                    }
                }
            } else {
                // otherwise, make a new one
                let todayJournal = firebaseServices.createNewJournalForUser(userID: uid, aid: user.id)
                // call firebase to add journal to users.journal array
            }
            // Combine everything into a MonkeyUser object
            return MonkeyUser(profile: user, journals: journals, foodCache: foodCache)
        } catch {
            print("Error fetching user information: \(error)")
            // Handle errors or return a default/fallback MonkeyUser object
            isLoading = false
            return MonkeyUser(profile: AppUser.empty, journals: [Journal.empty], foodCache: [:]) // Return an empty/default user on failure
        }
    }

    
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MacroMonkeyAuth())
            .environmentObject(MacroMonkeyDatabase())
            .environmentObject(SpoonacularService())
            .environmentObject(MonkeyUser(profile:AppUser.empty, journals:[Journal.empty], foodCache:[:]))
    }
}
