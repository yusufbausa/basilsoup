// Views/BackOffice/DashboardSection.swift

import SwiftUI

struct DashboardSection: View {

    @ObservedObject var boVM: BackOfficeViewModel
    @EnvironmentObject private var posVM:  POSViewModel
    @EnvironmentObject private var menuVM: MenuViewModel

    @State private var orderToDetail:  Order? = nil
    @State private var orderToEdit:    Order? = nil
    @State private var showDetailSheet: Bool  = false
    @State private var showEditSheet:   Bool  = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Dashboard")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.gold)
            statsGrid
            barChart
            recentOrdersTable
        }
        .sheet(isPresented: $showDetailSheet) {
            if let order = orderToDetail {
                OrderDetailSheet(
                    isPresented: $showDetailSheet,
                    order:       order,
                    posVM:       posVM,
                    menuVM:      menuVM
                )
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let order = orderToEdit {
                EditOrderSheet(isPresented: $showEditSheet, order: order, posVM: posVM, menuVM: menuVM) {}
            }
        }
    }

    // MARK: - Stats grid
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 14)], spacing: 14) {
            StatCard(label: "Today's Revenue",  value: boVM.todayRevenue.rp,    subLabel: "\(boVM.todayOrderCount) orders", color: .gold)
            StatCard(label: "Orders Today",     value: "\(boVM.todayOrderCount)",subLabel: "Dine-in & takeaway")
            StatCard(label: "Avg. Order",       value: boVM.averageOrder.rp,    subLabel: "Per transaction",                color: .success)
            StatCard(label: "All-Time Revenue", value: boVM.allTimeRevenue.rp,  subLabel: "\(boVM.allOrderCount) total",    color: .gold)
            StatCard(label: "Menu Items",       value: "\(boVM.menuItemCount)", subLabel: "\(boVM.availableCount) available")
        }
    }

    // MARK: - Bar chart
    private var barChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("REVENUE — LAST 7 DAYS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint).tracking(1.5)

            let data   = boVM.chartData
            let maxRev = data.map(\.revenue).max() ?? 1

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.label) { day in
                    BarColumn(label: day.label, revenue: day.revenue, maxRev: maxRev)
                }
            }
            .frame(height: 160).padding(.bottom, 4)
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color.border).frame(height: 1)
            }
        }
        .padding(18).cardStyle()
    }

    // MARK: - Recent orders table
    private var recentOrdersTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RECENT ORDERS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint).tracking(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Color.surface2)

            Divider().background(Color.border)
            OrdersTableHeader(showDate: true)
            Divider().background(Color.border)

            if boVM.recentOrders.isEmpty {
                Text("No orders yet")
                    .font(.system(size: 14)).foregroundColor(.textFaint)
                    .frame(maxWidth: .infinity).padding(30)
            } else {
                ForEach(boVM.recentOrders) { order in
                    OrdersTableRow(
                        order:    order,
                        showDate: true,
                        onDetail: {
                            orderToDetail = order
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showDetailSheet = true
                            }
                        },
                        onEdit: {
                            orderToEdit = order
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                showEditSheet = true
                            }
                        }
                    )
                    Divider().background(Color.border)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Bar column
private struct BarColumn: View {

    let label:   String
    let revenue: Double
    let maxRev:  Double

    private var heightFraction: CGFloat {
        maxRev > 0 ? CGFloat(revenue / maxRev) : 0
    }

    var body: some View {
        VStack(spacing: 4) {
            if revenue > 0 {
                Text(revenue.rp
                    .replacingOccurrences(of: "Rp ", with: "")
                    .replacingOccurrences(of: ".000", with: "k"))
                    .font(.system(size: 9)).foregroundColor(.textFaint)
            } else { Spacer() }
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gold3)
                .frame(maxWidth: .infinity)
                .frame(height: max(4, 120 * heightFraction))
            Text(label).font(.system(size: 10)).foregroundColor(.textFaint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Preview
#Preview {
    let posVM  = POSViewModel()
    let menuVM = MenuViewModel()
    let boVM   = BackOfficeViewModel()
    boVM.setup(posVM: posVM, menuVM: menuVM)
    return DashboardSection(boVM: boVM)
        .padding().background(Color.appBg)
        .environmentObject(posVM)
        .environmentObject(menuVM)
}
