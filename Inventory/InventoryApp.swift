
//  InventoryApp.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import SwiftUI
import UIKit
import Firebase

// Custom AppDelegate to configure Firebase and Firestore settings
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Firestore settings
        let settings = Firestore.firestore().settings
        
        // Customize settings for simulator environment
//        #if targetEnvironment(simulator)
//        settings.host = "localhost:9000"
//        settings.isPersistenceEnabled = false
//        settings.isSSLEnabled = false
//        #endif
        
        // Apply updated Firestore settings
        Firestore.firestore().settings = settings
        
        return true
    }
    
}

// Main app structure
@main
struct inventorytrackerApp: App {
    
    // Use AppDelegate as the UIApplicationDelegate adaptor
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
