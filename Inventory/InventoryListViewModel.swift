// InventoryListViewModel.swift
// Inventory
//
// Created by Brett Shirley on 6/21/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI
import Combine

class InventoryListViewModel: ObservableObject {
    @AppStorage("uid") var userID: String = ""
    @AppStorage("email") var email: String = ""
    
    private let warehouse: String
    private let db = Firestore.firestore()
    
    @Published var selectedSortType = SortType.createdAt
    @Published var isDescending = true
    @Published var items: [InventoryItem] = []
    @Published var searchQuery: String = ""
    
    init(warehouse: String) {
        self.warehouse = warehouse
    }
    
    // Fetches the inventory items for the selected warehouse
    func fetchInventoryItems() {
        let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")
        
        inventoryItemsRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot else {
                return
            }
            
            if let error = error {
                print("Error fetching inventory items for \(self.warehouse): \(error.localizedDescription)")
                return
            }
            
            do {
                // Decodes the retrieved documents into InventoryItem objects
                self.items = try snapshot.documents.compactMap { try $0.data(as: InventoryItem.self)}
                    self.sortItems()
            } catch {
                print("Error decoding inventory items: \(error.localizedDescription)")
            }
        }
    }
    
    // Adds a new item to the inventory
    func addItem() {
        let username = email.components(separatedBy: ".").first ?? ""
        
        let newItem = InventoryItem(name: "New Item", quantity: 1, createdBy: userID, lastEditedBy: username)
        do {
            let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")
            try inventoryItemsRef.addDocument(from: newItem)
        } catch {
            print("Error adding item: \(error.localizedDescription)")
        }
    }
    
    // Updates the name of an item
    func updateItemName(item: InventoryItem, newName: String) {
        let username = email.components(separatedBy: ".").first ?? ""
        
        guard item.name != newName else {
            return
        }
        
        guard let itemId = item.id else {
            return
        }
        
        // Updates the item's name and lastEditedBy field in Firestore
        let itemRef = db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId)
        itemRef.updateData(["name": newName, "lastEditedBy": username, "updatedAt": Date()]) { error in // Set lastEditedBy to the Username
            if let error = error {
                print("Error updating item: \(error.localizedDescription)")
            }
        }
    }
    
    // Handles changes to the quantity of an item
    func updateItemQuantity(item: InventoryItem, newQuantity: Int) {
        let username = email.components(separatedBy: ".").first ?? ""
        
        guard item.quantity != newQuantity else {
            return
        }
        
        guard let itemId = item.id else {
            return
        }
        
        // Updates the item's quantity and lastEditedBy field in Firestore
        let itemRef = db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId)
        itemRef.updateData(["quantity": newQuantity, "lastEditedBy": username, "updatedAt": Date()]) { error in // Set lastEditedBy to Username
            if let error = error {
                print("Error updating item: \(error.localizedDescription)")
            }
        }
    }
    
    // Deletes an item from the inventory
    func deleteItem(at index: Int) {
        guard items.indices.contains(index) else {
            return
        }
        
        let item = items[index]
        guard let itemId = item.id else {
            return
        }
        
        // Deletes the item from Firestore
        let itemRef = db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId)
        itemRef.delete { error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
    
    func sortItems() {
        switch selectedSortType {
        case .createdAt:
            items.sort { item1, item2 in
                if let date1 = item1.createdAt, let date2 = item2.createdAt {
                    return date1 < date2
                } else if item1.createdAt != nil {
                    return true
                } else {
                    return false
                }
            }
        case .updatedAt:
            items.sort { item1, item2 in
                if let date1 = item1.updatedAt, let date2 = item2.updatedAt {
                    return date1 < date2
                } else if item1.updatedAt != nil {
                    return true
                } else {
                    return false
                }
            }
        case .name:
            items.sort { $0.name < $1.name }
        case .quantity:
            items.sort { $0.quantity < $1.quantity }
        }
        
        if isDescending {
            items.reverse()
        }
    }
    
    // Computed property to get the filtered inventory items based on searchQuery
    var filteredItems: [InventoryItem] {
        if searchQuery.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
    }



}
