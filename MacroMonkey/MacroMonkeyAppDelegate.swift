//
//  MacroMonkeyAppDelegate.swift
//  MacroMonkey
//
//  Created by Alex Alvarez on 4/14/24.
//

import Foundation
import UIKit

// As a personal preference, I tend to put third-party library imports after the
// first-party iOS ones just so I know who’s responsible for what.
import Firebase

class MacroMonkeyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
