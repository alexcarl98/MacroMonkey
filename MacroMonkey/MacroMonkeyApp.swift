//
//  MacroMonkeyApp.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/9/24.
//

import SwiftUI

@main
struct MacroMonkeyApp: App {
    @UIApplicationDelegateAdaptor(MacroMonkeyAppDelegate.self) var appDelegate
    
    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(MacroMonkeyAuth())
//                .environmentObject(MacroMonkeyDatabase())
//                .environmentObject(SpoonacularService())
//                .environmentObject(MonkeyUser(profile:AppUser.empty, journals:[Journal.empty], foodCache:[:]))
//        }
        WindowGroup{
            MacroMonkeyDBHelperView()
                .environmentObject(MacroMonkeyDatabase())
                .environmentObject(SpoonacularService())
                .environmentObject(MonkeyUser(profile:AppUser.empty, journals:[Journal.empty], foodCache:[:]))
        }
    }
}
