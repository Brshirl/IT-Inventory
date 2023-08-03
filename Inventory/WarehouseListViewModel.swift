//  WarehouseListViewModel.swift
//  Inventory
//
//  Created by Brett Shirley on 6/26/23.
//

import Foundation
import Firebase

class WarehouseListViewModel: ObservableObject {
    @Published var warehouses: [String] = []

    // Fetches the list of warehouses
    func fetchWarehouses() {
        let db = Firestore.firestore()
        let warehousesRef = db.collection("inventories")

        // Fetches the documents from the "inventories" collection
        warehousesRef.getDocuments { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot else {
                return
            }

            if let error = error {
                // Handles the error if fetching warehouses fails
                print("Error fetching warehouses: \(error.localizedDescription)")
                return
            }

            // Maps the documents to an array of warehouse names
            self.warehouses = snapshot.documents.compactMap { $0.documentID }
        }
    }
}
