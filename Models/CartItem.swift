// Models/CartItem.swift
// ─────────────────────────────────────────────
// Represents one line in the active order.
// CartItem is NOT Codable — it only lives in memory
// while an order is being built. Once the order is
// confirmed it becomes an array of OrderLineItem.

import Foundation

struct CartItem: Identifiable, Equatable {

    let id:       UUID     = UUID()
    var menuItem: MenuItem
    var quantity: Int

    // Computed — always derived from source data, never stored
    var lineTotal: Double {
        menuItem.price * Double(quantity)
    }
}
