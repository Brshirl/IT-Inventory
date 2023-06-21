
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
    
    // MARK: - Properties
    
    private let db = Firestore.firestore().collection("inventories")
    
    // Published properties for view updates
    @Published var selectedSortType = SortType.createdAt
    @Published var isDescending = true
    @Published var editedName = ""
    
    // Computed property for Firestore query predicates
    var predicates: [QueryPredicate] { [.order(by: selectedSortType.rawValue, descending: isDescending)] }
    
    // MARK: - Item Manipulation Methods
    
    // Adds a new item to the inventory
    func addItem() {
        let item = InventoryItem(name: "New Item", quantity: 1)
        _ = try? db.addDocument(from: item)
    }
    
    // Updates an existing item in the inventory
    func updateItem(_ item: InventoryItem, data: [String: Any]) {
        guard let id = item.id else { return }
        var _data = data
        _data["updatedAt"] = FieldValue.serverTimestamp()
        db.document(id).updateData(_data)
    }
    
    // Deletes selected items from the inventory
    func onDelete(items: [InventoryItem], indexset: IndexSet) {
        for index in indexset {
            guard let id = items[index].id else { continue }
            db.document(id).delete()
        }
    }
    
    // Updates the edited name of an item
    func onEditingItemNameChanged(item: InventoryItem, isEditing: Bool) {
        if !isEditing {
            if item.name != editedName {
                updateItem(item, data: ["name": editedName])
            }
            editedName = ""
        } else {
            editedName = item.name
        }
    }
}
