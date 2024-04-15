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
        WindowGroup {
            ContentView()
                .environmentObject(MacroMonkeyAuth())
                .environmentObject(MacroMonkeyDatabase())
        }
    }
}
