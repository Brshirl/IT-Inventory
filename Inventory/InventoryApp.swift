//  InventoryApp.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import SwiftUI
import UIKit
import Firebase


@main
struct InventoryApp: App {
    init() {
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
    

    
    private func setupFirebase() {
        FirebaseApp.configure()
        
        let settings = Firestore.firestore().settings
        // Customize Firestore settings if needed
        // settings.host = "localhost:9000"
        // settings.isPersistenceEnabled = false
        // settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
    }
}
