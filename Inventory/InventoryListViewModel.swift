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
                self.items = try snapshot.documents.compactMap { try $0.data(as: InventoryItem.self) }
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
        itemRef.updateData(["name": newName, "lastEditedBy": username]) { error in // Set lastEditedBy to the user's UID
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
        itemRef.updateData(["quantity": newQuantity, "lastEditedBy": username]) { error in // Set lastEditedBy to the user's UID
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
}
