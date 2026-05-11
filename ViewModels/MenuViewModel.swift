// ViewModels/MenuViewModel.swift
// ─────────────────────────────────────────────
// Owns the full menu list and all CRUD operations:
//   • Load / save menu to UserDefaults via Persistence
//   • Add, delete, toggle availability
//   • Filtered menu for POS grid
//
// Shared between POSView (read) and MenuSection (write).

import Foundation
import Combine

final class MenuViewModel: ObservableObject {

    // MARK: - Published state

    @Published var menu:            [MenuItem] = []
    @Published var activeCategory:  String     = "All"

    // MARK: - Init

    init() {
        loadMenu()
    }

    // MARK: - Filtered menu for POS grid

    var filteredMenu: [MenuItem] {
        guard activeCategory != "All" else { return menu }
        return menu.filter { $0.category == activeCategory }
    }

    // MARK: - CRUD

    /// Adds a new item to the menu and persists.
    func addItem(name: String, price: Double, category: String, emoji: String) {
        let item = MenuItem(
            name:     name,
            price:    price,
            category: category,
            emoji:    emoji.isEmpty ? "🍽" : emoji
        )
        menu.append(item)
        saveMenu()
    }

    /// Flips the availability flag for a given item.
    func toggleAvailability(of item: MenuItem) {
        guard let index = menu.firstIndex(where: { $0.id == item.id }) else { return }
        menu[index].isAvailable.toggle()
        saveMenu()
    }

    /// Permanently removes an item from the menu.
    func deleteItem(_ item: MenuItem) {
        menu.removeAll { $0.id == item.id }
        saveMenu()
    }

    /// Updates an existing menu item's editable fields.
    func updateItem(_ item: MenuItem,
                    name:     String,
                    price:    Double,
                    category: String,
                    emoji:    String) {
        guard let index = menu.firstIndex(where: { $0.id == item.id }) else { return }
        menu[index].name     = name
        menu[index].price    = price
        menu[index].category = category
        menu[index].emoji    = emoji.isEmpty ? "🍽" : emoji
        saveMenu()
    }

    // MARK: - Computed helpers

    var availableCount: Int {
        menu.filter(\.isAvailable).count
    }

    // MARK: - Persistence

    private func loadMenu() {
        menu = Persistence.load([MenuItem].self, forKey: Persistence.Key.menu)
            ?? MenuItem.defaultMenu
    }

    func saveMenu() {
        Persistence.save(menu, forKey: Persistence.Key.menu)
    }
}
