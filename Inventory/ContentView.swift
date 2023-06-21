//  ContentView.swift
//  Inventory
//
//  Created by Brett Shirley on 6/21/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct ContentView: View {
    
    // Firestore query for fetching inventory items
    @FirestoreQuery(collectionPath: "inventories",
                    predicates: [.order(by: SortType.createdAt.rawValue, descending: true)])
    private var items: [InventoryItem]
    
    // View model for managing inventory list
    @StateObject private var vm = InventoryListViewModel()
    
    var body: some View {
        VStack {
            // Display error message if there's an error fetching items
            if let error = $items.error {
                Text(error.localizedDescription)
            }
            
            // Display the list of items if there are items available
            if items.count > 0 {
                List {
                    sortBySectionView
                    listItemsSectionView
                }
                .listStyle(.insetGrouped)
            }
        }
        .toolbar {
            // Add button for adding new items to the inventory
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("+") { vm.addItem() }.font(.title)
            }
            
            // Edit button for editing items in the inventory
            ToolbarItem(placement: .navigationBarLeading) { EditButton() }
        }
        .onChange(of: vm.selectedSortType) { _ in onSortTypeChanged() }
        .onChange(of: vm.isDescending) { _ in onSortTypeChanged() }
        .navigationTitle("Inventory")
    }
    
    // View for displaying the list of inventory items
    private var listItemsSectionView: some View {
        Section {
            ForEach(items) { item in
                VStack {
                    // Text field for editing the name of the item
                    TextField("Name", text: Binding<String>(
                        get: { item.name },
                        set: { vm.editedName = $0 }),
                              onEditingChanged: { vm.onEditingItemNameChanged(item: item, isEditing: $0)}
                    )
                    .disableAutocorrection(true)
                    .font(.headline)
                    
                    // Stepper for adjusting the quantity of the item
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
    
    // Method called when the sort type or sort order changes
    private func onSortTypeChanged() {
        $items.predicates = vm.predicates
    }
      
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
