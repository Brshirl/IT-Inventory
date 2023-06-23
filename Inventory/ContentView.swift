import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct ContentView: View {

    @StateObject private var vm = InventoryListViewModel()
    @State private var warehouses: [String] = []

    var body: some View {
        VStack {
            if warehouses.isEmpty {
                Text("No warehouses found.")
            } else {
                List(warehouses, id: \.self) { warehouse in
                    NavigationLink(destination: InventoryItemsView(warehouse: warehouse)) {
                        Text(warehouse)
                    }
                }
            }
        }
        .onAppear {
            fetchWarehouses()
        }
    }

    private func fetchWarehouses() {
        let db = Firestore.firestore()
        let warehousesRef = db.collection("inventories")

        warehousesRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching warehouses: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No warehouses found.")
                return
            }

            warehouses = documents.compactMap { $0.documentID }
        }
    }
}

struct InventoryItemsView: View {
    let warehouse: String
    @State private var items: [InventoryItem] = []

    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No items found in \(warehouse).")
            } else {
                List(items) { item in
                    // Display item details
                }
            }
        }
        .onAppear {
            fetchInventoryItems()
        }
    }

    private func fetchInventoryItems() {
        let db = Firestore.firestore()
        let inventoryItemsRef = db.collection("inventories").document(warehouse).collection("inventoryItems")

        inventoryItemsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching inventory items for \(warehouse): \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No items found in \(warehouse).")
                return
            }

            do {
                items = try documents.compactMap { try $0.data(as: InventoryItem.self) }
            } catch {
                print("Error decoding inventory items: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
