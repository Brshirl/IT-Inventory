
//  Sort.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import Foundation



enum SortType: String, CaseIterable {
    
    case createdAt
    case updatedAt
    case name
    case quantity
    
    var text: String {
        switch self {
        case .createdAt: return "Created At"
        case .updatedAt: return "Updated At"
        case .name: return "Name"
        case .quantity: return "Quantity"
        }
    }
    
}
