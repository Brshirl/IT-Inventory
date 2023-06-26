//
//  WarehouseListViewModel.swift
//  Inventory
//
//  Created by Brett Shirley on 6/26/23.
//

import Foundation
import Firebase

class WarehouseListViewModel: ObservableObject {
    @Published var warehouses: [String] = []

    func fetchWarehouses() {
        let db = Firestore.firestore()
        let warehousesRef = db.collection("inventories")

        warehousesRef.getDocuments { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot else {
                return
            }

            if let error = error {
                print("Error fetching warehouses: \(error.localizedDescription)")
                return
            }

            self.warehouses = snapshot.documents.compactMap { $0.documentID }
        }
    }
}
