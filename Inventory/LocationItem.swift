
//  InventoryItem.swift
//  Location
//
//  Created by Brett Shirley on 6/21/23.
//

import Foundation
import FirebaseFirestoreSwift


struct LocationItem: Identifiable, Codable{
    
    @DocumentID var id: String?
    var name: String
}
