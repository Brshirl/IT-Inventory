import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct ContentView: View {
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
        .navigationTitle("Locations")
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
    @StateObject private var vm: InventoryListViewModel // Use separate view model instances for each warehouse

    let warehouse: String
    @State private var items: [InventoryItem] = []

    init(warehouse: String) {
        self.warehouse = warehouse
        _vm = StateObject(wrappedValue: InventoryListViewModel()) // Create a new instance of the view model
    }

    var body: some View {
        VStack {
            if items.isEmpty {
                Text("No items found in \(warehouse).")
            } else {
                List {
                    sortBySectionView // Move the sortBySectionView outside of the List
                    listItemsSectionView // Move the listItemsSectionView outside of the List
                }
                .listStyle(.insetGrouped)
            }
        }
        .onAppear {
            fetchInventoryItems()
        }
        .navigationTitle("Inventory")
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
    
    // View for displaying the sort by section
    private var sortBySectionView: some View {
        Section {
            DisclosureGroup("Sort by") {
                Picker("Sort by", selection: $vm.selectedSortType) {
                    ForEach(SortType.allCases, id: \.rawValue) { sortType in
                        Text(sortType.text).tag(sortType)
                    }
                }.pickerStyle(.segmented)
                
                Toggle("Is Descending", isOn: $vm.isDescending)
            }
        }
    }
    
    // View for displaying the list of inventory items
    private var listItemsSectionView: some View {
        Section {
            ForEach(items) { item in
                VStack {
                    TextField("Name", text: Binding<String>(
                        get: { item.name },
                        set: { vm.editedName = $0 }),
                              onEditingChanged: { vm.onEditingItemNameChanged(item: item, isEditing: $0)}
                    )
                    .disableAutocorrection(true)
                    .font(.headline)
                    
                    Stepper("Quantity: \(item.quantity)",
                            value: Binding<Int>(
                                get: { item.quantity },
                                set: { vm.updateItem(item, data: ["quantity": $0]) }),
                            in: 0...1000)
                }
            }
            .onDelete { vm.onDelete(items: items, indexset: $0) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
