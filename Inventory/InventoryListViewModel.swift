//  InventoryListViewModel.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class InventoryListViewModel: ObservableObject {
    private let warehouse: String
    private let db = Firestore.firestore()

    @Published var selectedSortType = SortType.createdAt
    @Published var isDescending = true
    @Published var editedName = ""
    @Published var editedQuantity = 0
    @Published var items: [InventoryItem] = []

    init(warehouse: String) {
        self.warehouse = warehouse
    }

    // Fetches the inventory items for the selected warehouse
    func fetchInventoryItems() {
        let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")

        inventoryItemsRef.getDocuments { [weak self] snapshot, error in
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
        let newItem = InventoryItem(name: "New Item", quantity: 1, createdBy: "Name")
        do {
            let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")
            try inventoryItemsRef.addDocument(from: newItem)
        } catch {
            print("Error adding item: \(error.localizedDescription)")
        }
    }


    // Updates the name of an item
    func onEditingItemNameChanged(item: InventoryItem, newName: String) {
        guard item.name != newName else {
            return
        }
        
        guard let itemIndex = items.firstIndex(of: item) else {
            return
        }

        items[itemIndex].name = newName
        
        let updatedData = ["name": newName]
        guard let itemId = item.id else {
            return
        }

        // Updates the item's name in Firestore
        let itemRef = db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId)
        itemRef.updateData(updatedData) { error in
            if let error = error {
                print("Error updating item: \(error.localizedDescription)")
            }
        }
    }


    // Handles changes to the quantity of an item
    func onEditingQuantityChanged(item: InventoryItem, newQuantity: Int) {
        guard item.quantity != newQuantity else {
            return
        }
        
        guard let itemIndex = items.firstIndex(of: item) else {
            return
        }
        
        items[itemIndex].quantity = newQuantity

        let updatedData = ["quantity": newQuantity]
        guard let itemId = item.id else {
            return
        }

        // Updates the item's quantity in Firestore
        db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId).updateData(updatedData) { error in
            if let error = error {
                print("Error updating item: \(error.localizedDescription)")
            }
        }
    }

    // Deletes an item from the inventory
    func onDelete(indexSet: IndexSet) {
        guard let index = indexSet.first, items.indices.contains(index) else {
            return
        }

        let item = items[index]
        guard let itemId = item.id else {
            return
        }

        // Deletes the item from Firestore
        db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId).delete() { error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
}
