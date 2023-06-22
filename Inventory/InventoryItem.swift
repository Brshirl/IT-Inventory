
//  InventoryItem.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import Foundation
import FirebaseFirestoreSwift


struct InventoryItem: Identifiable, Codable{
    
    @DocumentID var id: String?
    
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
    
    var name: String
    var quantity: Int
    var createdBy: String
}
