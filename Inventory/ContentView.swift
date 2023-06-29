/*
Brett Shirley
6/26/23
*/

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

// View for displaying the list of warehouses
struct ContentView: View {
    @StateObject private var viewModel = WarehouseListViewModel()
    @AppStorage("uid") var userID: String = ""
    var body: some View {
        VStack {
            if viewModel.warehouses.isEmpty {
                Text("No warehouses found.")
            } else {
                List(viewModel.warehouses, id: \.self) { warehouse in
                    // Navigate to the inventory items view when a warehouse is selected
                    NavigationLink(destination: InventoryItemsView(warehouse: warehouse)) {
                        Text(warehouse)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchWarehouses()
        }
        .navigationTitle("Locations")
    }
}

// View for displaying the inventory items of a specific warehouse
struct InventoryItemsView: View {
    @StateObject private var viewModel: InventoryListViewModel

    let warehouse: String

    init(warehouse: String) {
        self.warehouse = warehouse
        _viewModel = StateObject(wrappedValue: InventoryListViewModel(warehouse: warehouse))
    }

    var body: some View {
        VStack {
            if viewModel.items.isEmpty {
                Text("No items found in \(warehouse).")
            } else {
                List {
                  //  SortBySectionView(viewModel: viewModel)
                    ListItemsSectionView(viewModel: viewModel)
                }
                .listStyle(.insetGrouped)
            }
        }
        .onAppear {
            viewModel.fetchInventoryItems()
        }
        .navigationTitle("Inventory")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.addItem()
                    viewModel.fetchInventoryItems()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

// View for the sort by section in the inventory items view
struct SortBySectionView: View {
    @ObservedObject var viewModel: InventoryListViewModel

    var body: some View {
        Section {
            DisclosureGroup("Sort by") {
                // Picker for selecting the sort type
                Picker("Sort by", selection: $viewModel.selectedSortType) {
                    ForEach(SortType.allCases, id: \.rawValue) { sortType in
                        Text(sortType.text).tag(sortType)
                    }
                }
                .pickerStyle(.segmented)
                
                // Toggle for selecting the sort order (ascending or descending)
                Toggle("Is Descending", isOn: $viewModel.isDescending)
            }
        }
    }
}


// View for displaying the list of inventory items
struct ListItemsSectionView: View {
    @ObservedObject var viewModel: InventoryListViewModel

    var body: some View {
        Section {
            ForEach(viewModel.items) { item in
                VStack {
                    // Text field for editing the item name
                    TextField("Name", text: Binding(
                        get: { item.name },
                        set: { viewModel.onEditingItemNameChanged(item: item, newName: $0) }
                    ))
                    .disableAutocorrection(true)
                    .font(.headline)
                    
                    // Stepper for editing the item quantity
                    Stepper("Quantity: \(item.quantity)", value: Binding(
                        get: { item.quantity },
                        set: { viewModel.onEditingQuantityChanged(item: item, newQuantity: $0) }
                    ), in: 0...1000)
                }
            }
            .onDelete { indexSet in
                viewModel.onDelete(indexSet: indexSet)
                viewModel.fetchInventoryItems()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
