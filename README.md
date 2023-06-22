# IT-Inventory
IT Inventory simple app made in swift, with CRUD functionality with access to FIREBASE
Summary: IT Inventory Management Project

The IT Inventory Management project is a SwiftUI-based application that allows users to manage and track inventory items for different locations. The application integrates with Firebase Firestore to store and retrieve inventory data. It provides features such as adding, editing, and deleting inventory items, as well as sorting items based on different criteria.

The main components of the project are:

1. ContentView: The main view of the application, displaying a list of inventory items and various sections for managing the inventory. It also includes sorting options and buttons for adding and editing items.

2. InventoryListViewModel: A view model that handles the logic for managing the inventory list. It communicates with Firebase Firestore to fetch and update inventory data. It also manages the sorting options and provides functions for adding, editing, and deleting items.

3. FirestoreQuery: A property wrapper used in the ContentView to fetch inventory items from Firestore. It allows specifying predicates for ordering the items based on different criteria.

4. InventoryItem: A struct representing an individual inventory item. It includes properties like name, quantity, and creation timestamp.

5. SortType: An enum representing different sorting options for the inventory list, such as sorting by name, quantity, or creation timestamp.

6. WarhorseInventoryListView: A separate view for displaying warhorse inventories for a specific location. It fetches the inventories from Firestore based on the selected location and displays them in a list.

7. WarhorseInventoryListViewModel: A view model for managing the warhorse inventory list. It fetches the inventories for a specific location from Firestore and provides loading state, error handling, and data management functionalities.

The project allows users to organize and track IT inventory items effectively. They can add, edit, and delete items, as well as sort them based on different criteria. Additionally, users can select a location and view the corresponding warhorse inventories.

By leveraging SwiftUI and Firebase Firestore, the IT Inventory Management project provides a user-friendly interface and seamless integration with a cloud database, making it a reliable and efficient solution for managing IT inventory in various locations.
