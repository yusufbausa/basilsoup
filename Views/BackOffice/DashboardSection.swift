// Views/BackOffice/DashboardSection.swift
// ─────────────────────────────────────────────
// Back Office → Dashboard tab.
// Shows KPI stat cards, a 7-day bar chart,
// and a table of the 10 most recent orders.

import SwiftUI

struct DashboardSection: View {

    // Passed in directly (not via environment) so the
    // view is explicit about its dependency.
    @ObservedObject var boVM: BackOfficeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text("Dashboard")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.gold)

            statsGrid
            barChart
            recentOrdersTable
        }
    }

    // MARK: - Stats grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 155), spacing: 14)],
            spacing: 14
        ) {
            StatCard(label: "Today's Revenue", value: boVM.todayRevenue.rp,    subLabel: "\(boVM.todayOrderCount) orders",  color: .gold)
            StatCard(label: "Orders Today",    value: "\(boVM.todayOrderCount)",subLabel: "Dine-in & takeaway")
            StatCard(label: "Avg. Order",      value: boVM.averageOrder.rp,     subLabel: "Per transaction",                color: .success)
            StatCard(label: "All-Time Revenue",value: boVM.allTimeRevenue.rp,   subLabel: "\(boVM.allOrderCount) total",    color: .gold)
            StatCard(label: "Menu Items",      value: "\(boVM.menuItemCount)",  subLabel: "\(boVM.availableCount) available")
        }
    }

    // MARK: - Bar chart

    private var barChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("REVENUE — LAST 7 DAYS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint)
                .tracking(1.5)

            let data   = boVM.chartData
            let maxRev = data.map(\.revenue).max() ?? 1

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(data, id: \.label) { day in
                    BarColumn(
                        label:   day.label,
                        revenue: day.revenue,
                        maxRev:  maxRev
                    )
                }
            }
            .frame(height: 160)
            .padding(.bottom, 4)
            .overlay(alignment: .bottom) {
                // Base line
                Rectangle()
                    .fill(Color.border)
                    .frame(height: 1)
            }
        }
        .padding(18)
        .cardStyle()
    }

    // MARK: - Recent orders table

    private var recentOrdersTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("RECENT ORDERS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textFaint)
                    .tracking(1.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface2)

            Divider().background(Color.border)
            OrdersTableHeader()
            Divider().background(Color.border)

            if boVM.recentOrders.isEmpty {
                Text("No orders yet")
                    .font(.system(size: 14))
                    .foregroundColor(.textFaint)
                    .frame(maxWidth: .infinity)
                    .padding(30)
            } else {
                ForEach(boVM.recentOrders) { order in
                    OrdersTableRow(order: order)
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
            // Value label above bar
            if revenue > 0 {
                Text(revenue.rp
                    .replacingOccurrences(of: "Rp ", with: "")
                    .replacingOccurrences(of: ".000", with: "k"))
                    .font(.system(size: 9))
                    .foregroundColor(.textFaint)
            } else {
                Spacer()
            }
            // Bar
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gold3)
                .frame(maxWidth: .infinity)
                .frame(height: max(4, 120 * heightFraction))
            // Day label
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.textFaint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Preview
#Preview {
    let posVM  = POSViewModel()
    let menuVM = MenuViewModel()
    DashboardSection(boVM: BackOfficeViewModel(posVM: posVM, menuVM: menuVM))
        .padding()
        .background(Color.appBg)
}
