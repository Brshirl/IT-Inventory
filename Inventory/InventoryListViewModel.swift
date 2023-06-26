
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
                   self.items = try snapshot.documents.compactMap { try $0.data(as: InventoryItem.self) }
               } catch {
                   print("Error decoding inventory items: \(error.localizedDescription)")
               }
           }
       }

       func addItem() {
           let newItem = InventoryItem(name: "New Item", quantity: 1, createdBy: "Name")
           do {
               let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")
               try inventoryItemsRef.addDocument(from: newItem)
           } catch {
               print("Error adding item: \(error.localizedDescription)")
           }
       }

       func onEditingItemNameChanged(item: InventoryItem) {
           guard item.name != editedName else {
               return
           }

           let updatedData = ["name": editedName]
           guard let itemId = item.id else {
               return
           }

           db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId).updateData(updatedData) { error in
               if let error = error {
                   print("Error updating item: \(error.localizedDescription)")
               }
           }
       }

       func onEditingQuantityChanged(item: InventoryItem, isEditing: Bool) {
           guard isEditing else {
               let updatedData = ["quantity": editedQuantity]
               guard let itemId = item.id else {
                   return
               }

               db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId).updateData(updatedData) { error in
                   if let error = error {
                       print("Error updating item: \(error.localizedDescription)")
                   }
               }
               return
           }

           editedQuantity = item.quantity
       }

       func onDelete(indexSet: IndexSet) {
           guard let index = indexSet.first, items.indices.contains(index) else {
               return
           }

           let item = items[index]
           guard let itemId = item.id else {
               return
           }

           db.collection("inventories").document(warehouse).collection("inventoryItems").document(itemId).delete() { error in
               if let error = error {
                   print("Error deleting item: \(error.localizedDescription)")
               }
           }
       }
   }
