// ViewModels/BackOfficeViewModel.swift
// ─────────────────────────────────────────────
// Derives dashboard statistics from POSViewModel's
// orders array. Does NOT own any data itself —
// it reads from POSViewModel and MenuViewModel,
// keeping a single source of truth.
//
// BackOfficeView creates this locally and passes
// the two shared VMs in via the constructor.

import Foundation
import Combine

final class BackOfficeViewModel: ObservableObject {

    // MARK: - Dependencies (injected, not owned)

    private let posVM:  POSViewModel
    private let menuVM: MenuViewModel

    // MARK: - Published state

    @Published var orderTypeFilter: Order.OrderType? = nil  // nil = show all
    @Published var searchText:      String           = ""

    // MARK: - Init

    init(posVM: POSViewModel, menuVM: MenuViewModel) {
        self.posVM  = posVM
        self.menuVM = menuVM
    }

    // MARK: - Dashboard stats

    var todayRevenue:    Double { posVM.todayRevenue }
    var todayOrderCount: Int    { posVM.todayOrders.count }
    var averageOrder:    Double { posVM.averageOrderValue }
    var allTimeRevenue:  Double { posVM.allTimeRevenue }
    var allOrderCount:   Int    { posVM.orders.count }
    var menuItemCount:   Int    { menuVM.menu.count }
    var availableCount:  Int    { menuVM.availableCount }

    var recentOrders: [Order] {
        Array(posVM.orders.prefix(10))
    }

    var chartData: [(label: String, revenue: Double)] {
        posVM.revenueLastSevenDays()
    }

    // MARK: - Filtered orders for Orders section

    var filteredOrders: [Order] {
        posVM.orders
            .filter { order in
                // Type filter
                guard let typeFilter = orderTypeFilter else { return true }
                return order.type == typeFilter
            }
            .filter { order in
                // Search filter — matches order number
                guard !searchText.isEmpty else { return true }
                return String(order.orderNumber).contains(searchText)
            }
    }
}
