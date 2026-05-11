// ViewModels/BackOfficeViewModel.swift

import Foundation
import Combine

final class BackOfficeViewModel: ObservableObject {

    // MARK: - Dependencies (set via setup, not init)
    private var posVM:  POSViewModel?
    private var menuVM: MenuViewModel?

    // MARK: - Published state
    @Published var orderTypeFilter: Order.OrderType? = nil
    @Published var searchText:      String           = ""

    // MARK: - Init & setup
    init() {}

    func setup(posVM: POSViewModel, menuVM: MenuViewModel) {
        self.posVM  = posVM
        self.menuVM = menuVM
    }

    // MARK: - Dashboard stats
    var todayRevenue:    Double { posVM?.todayRevenue    ?? 0 }
    var todayOrderCount: Int    { posVM?.todayOrders.count ?? 0 }
    var averageOrder:    Double { posVM?.averageOrderValue ?? 0 }
    var allTimeRevenue:  Double { posVM?.allTimeRevenue  ?? 0 }
    var allOrderCount:   Int    { posVM?.orders.count    ?? 0 }
    var menuItemCount:   Int    { menuVM?.menu.count     ?? 0 }
    var availableCount:  Int    { menuVM?.availableCount ?? 0 }

    var recentOrders: [Order] {
        Array((posVM?.orders ?? []).prefix(10))
    }

    var chartData: [(label: String, revenue: Double)] {
        posVM?.revenueLastSevenDays() ?? []
    }

    // MARK: - Filtered orders
    var filteredOrders: [Order] {
        (posVM?.orders ?? [])
            .filter { order in
                guard let typeFilter = orderTypeFilter else { return true }
                return order.type == typeFilter
            }
            .filter { order in
                guard !searchText.isEmpty else { return true }
                return String(order.orderNumber).contains(searchText)
            }
    }
}
