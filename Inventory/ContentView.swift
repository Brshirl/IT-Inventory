import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WarehouseListViewModel()

    var body: some View {
        VStack {
            if viewModel.warehouses.isEmpty {
                Text("No warehouses found.")
            } else {
                List(viewModel.warehouses, id: \.self) { warehouse in
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
                    SortBySectionView(viewModel: viewModel)
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
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct SortBySectionView: View {
    @ObservedObject var viewModel: InventoryListViewModel

    var body: some View {
        Section {
            DisclosureGroup("Sort by") {
                Picker("Sort by", selection: $viewModel.selectedSortType) {
                    ForEach(SortType.allCases, id: \.rawValue) { sortType in
                        Text(sortType.text).tag(sortType)
                    }
                }
                .pickerStyle(.segmented)
                
                Toggle("Is Descending", isOn: $viewModel.isDescending)
            }
        }
    }
}

struct ListItemsSectionView: View {
    @ObservedObject var viewModel: InventoryListViewModel

    var body: some View {
        Section {
            ForEach(viewModel.items) { item in
                VStack {
                    TextField("Name", text: $viewModel.editedName)
                        .disableAutocorrection(true)
                        .font(.headline)
                        .onAppear {
                            viewModel.editedName = item.name
                        }
                        .onDisappear {
                            viewModel.onEditingItemNameChanged(item: item)
                        }
                    
                    Stepper("Quantity: \(item.quantity)", value: $viewModel.editedQuantity, in: 0...1000) { isEditing in
                        viewModel.onEditingQuantityChanged(item: item, isEditing: isEditing)
                    }
                }
            }
            .onDelete { indexSet in
                viewModel.onDelete(indexSet: indexSet)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
