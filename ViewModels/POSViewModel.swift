// ViewModels/POSViewModel.swift

import Foundation
import Combine

final class POSViewModel: ObservableObject {

    // MARK: - Published state
    @Published var cart:          [CartItem]      = []
    @Published var orderType:     Order.OrderType = .dineIn
    @Published var selectedTable: String          = ""
    @Published var orders:        [Order]         = []

    static let taxRate:  Double = 0.0
    let availableTables: [String] = (1...10).map { "Table \($0)" }

    init() { loadOrders() }

    // MARK: - Cart totals
    var cartSubtotal: Double { cart.reduce(0) { $0 + $1.lineTotal } }
    var cartTax:      Double { cartSubtotal * Self.taxRate }
    var cartTotal:    Double { cartSubtotal + cartTax }
    var cartItemCount:Int    { cart.reduce(0) { $0 + $1.quantity } }
    var isCartEmpty:  Bool   { cart.isEmpty }

    // MARK: - Cart mutations
    func addToCart(_ item: MenuItem) {
        guard item.isAvailable else { return }
        if let index = cart.firstIndex(where: { $0.menuItem.id == item.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(CartItem(menuItem: item, quantity: 1))
        }
    }

    func increment(_ cartItem: CartItem) {
        guard let index = cart.firstIndex(where: { $0.id == cartItem.id }) else { return }
        cart[index].quantity += 1
    }

    func decrement(_ cartItem: CartItem) {
        guard let index = cart.firstIndex(where: { $0.id == cartItem.id }) else { return }
        if cart[index].quantity > 1 { cart[index].quantity -= 1 }
        else { cart.remove(at: index) }
    }

    func clearCart() {
        cart = []; selectedTable = ""; orderType = .dineIn
    }

    // MARK: - Checkout
    @discardableResult
    func confirmOrder() -> Order {
        let lineItems = cart.map {
            OrderLineItem(name: $0.menuItem.name, price: $0.menuItem.price, quantity: $0.quantity)
        }
        let order = Order(
            orderNumber: nextOrderNumber,
            type:        orderType,
            table:       orderType == .dineIn ? selectedTable.nilIfEmpty : nil,
            items:       lineItems,
            subtotal:    cartSubtotal,
            tax:         cartTax,
            total:       cartTotal
        )
        orders.insert(order, at: 0)
        saveOrders()
        clearCart()
        return order
    }

    // MARK: - Edit existing order
    func updateOrder(_ order: Order,
                     items: [OrderLineItem],
                     type: Order.OrderType,
                     table: String?) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].items          = items
        orders[index].type           = type
        orders[index].table          = type == .dineIn ? table?.nilIfEmpty : nil
        orders[index].status         = .edited
        orders[index].lastEditedDate = Date()
        orders[index].recalculate(taxRate: Self.taxRate)
        saveOrders()
    }

    // MARK: - Stats
    var todayOrders: [Order] {
        let today = Calendar.current.startOfDay(for: Date())
        return orders.filter { $0.date >= today }
    }
    var todayRevenue:    Double { todayOrders.reduce(0) { $0 + $1.total } }
    var allTimeRevenue:  Double { orders.reduce(0) { $0 + $1.total } }
    var averageOrderValue: Double {
        todayOrders.isEmpty ? 0 : todayRevenue / Double(todayOrders.count)
    }

    func revenueLastSevenDays() -> [(label: String, revenue: Double)] {
        (0..<7).reversed().map { daysAgo in
            let date  = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            let start = Calendar.current.startOfDay(for: date)
            let end   = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            let rev   = orders.filter { $0.date >= start && $0.date < end }.reduce(0) { $0 + $1.total }
            let label = daysAgo == 0 ? "Today" : date.formatted(.dateTime.weekday(.abbreviated))
            return (label, rev)
        }
    }

    // MARK: - Persistence
    private func loadOrders() {
        orders = Persistence.load([Order].self, forKey: Persistence.Key.orders) ?? []
    }
    func saveOrders() {
        Persistence.save(orders, forKey: Persistence.Key.orders)
    }
    private var nextOrderNumber: Int {
        (orders.map(\.orderNumber).max() ?? 1000) + 1
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
