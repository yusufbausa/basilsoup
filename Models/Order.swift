// Models/Order.swift
// ─────────────────────────────────────────────
// Snapshot of a completed transaction.
// Orders can be edited after submission —
// edits are tracked via lastEditedDate.

import Foundation

// MARK: - OrderLineItem
struct OrderLineItem: Codable, Equatable {
    var name:     String
    var price:    Double
    var quantity: Int

    var lineTotal: Double { price * Double(quantity) }
}

// MARK: - Order
struct Order: Identifiable, Codable {

    var id:             UUID        = UUID()
    var orderNumber:    Int
    var type:           OrderType
    var table:          String?
    var items:          [OrderLineItem]
    var subtotal:       Double
    var tax:            Double
    var total:          Double
    var date:           Date        = Date()
    var status:         OrderStatus = .paid
    var lastEditedDate: Date?       = nil   // set whenever order is edited

    // MARK: Nested enums

    enum OrderType: String, Codable, CaseIterable {
        case dineIn   = "Dine-in"
        case takeaway = "Takeaway"
    }

    enum OrderStatus: String, Codable {
        case paid     = "Paid"
        case edited   = "Edited"
        case refunded = "Refunded"
    }

    // MARK: Computed helpers
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var tableDisplay: String {
        table ?? "—"
    }

    var wasEdited: Bool {
        lastEditedDate != nil
    }

    // Recalculate totals from current items
    mutating func recalculate(taxRate: Double = 0.0) {
        subtotal = items.reduce(0) { $0 + $1.lineTotal }
        tax      = subtotal * taxRate
        total    = subtotal + tax
    }
}
