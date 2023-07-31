
//  InventoryItem.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import Foundation
import FirebaseFirestoreSwift


struct InventoryItem: Identifiable, Codable, Equatable{
    
    @DocumentID var id: String?
    
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    var name: String
    var quantity: Int
    var createdBy: String
    var lastEditedBy: String
    var category: String
    
    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        // Compare the properties that make two inventory items equal
        return lhs.id == rhs.id
    }
    
}
