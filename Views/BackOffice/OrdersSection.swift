// Views/BackOffice/OrdersSection.swift

import SwiftUI

// MARK: - OrdersSection

struct OrdersSection: View {

    @ObservedObject var boVM: BackOfficeViewModel
    @EnvironmentObject private var posVM:  POSViewModel
    @EnvironmentObject private var menuVM: MenuViewModel

    @State private var orderToEdit:    Order? = nil
    @State private var orderToDetail:  Order? = nil
    @State private var showEditSheet:   Bool  = false
    @State private var showDetailSheet: Bool  = false
    @State private var showSavedToast:  Bool  = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("All Orders")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.gold)
            filterBar
            ordersTable
        }
        // Detail sheet
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
        // Edit sheet
        .sheet(isPresented: $showEditSheet) {
            if let order = orderToEdit {
                EditOrderSheet(isPresented: $showEditSheet, order: order, posVM: posVM, menuVM: menuVM) {
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showSavedToast = false }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showSavedToast {
                Text("✅ Order updated successfully")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Color.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.border2, lineWidth: 1))
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showSavedToast)
            }
        }
    }

    // MARK: - Filter bar
    private var filterBar: some View {
        HStack(spacing: 8) {
            FilterPill(label: "All",      isActive: boVM.orderTypeFilter == nil)      { boVM.orderTypeFilter = nil }
            FilterPill(label: "Dine-in",  isActive: boVM.orderTypeFilter == .dineIn)  { boVM.orderTypeFilter = .dineIn }
            FilterPill(label: "Takeaway", isActive: boVM.orderTypeFilter == .takeaway){ boVM.orderTypeFilter = .takeaway }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 12)).foregroundColor(.textFaint)
                TextField("Search order #…", text: $boVM.searchText)
                    .font(.system(size: 13)).foregroundColor(.textPrimary).tint(.gold).frame(width: 160)
            }
            .padding(.horizontal, 10).padding(.vertical, 7)
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
        }
    }

    // MARK: - Orders table
    private var ordersTable: some View {
        VStack(spacing: 0) {
            OrdersTableHeader(showDate: true)
            Divider().background(Color.border)
            if boVM.filteredOrders.isEmpty {
                Text("No orders found")
                    .font(.system(size: 14)).foregroundColor(.textFaint)
                    .frame(maxWidth: .infinity).padding(30)
            } else {
                ForEach(boVM.filteredOrders) { order in
                    OrdersTableRow(
                        order:    order,
                        showDate: true,
                        onDetail: {
                            orderToDetail  = order
                            showDetailSheet = true
                        },
                        onEdit: {
                            orderToEdit   = order
                            showEditSheet = true
                        }
                    )
                    Divider().background(Color.border)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - FilterPill
struct FilterPill: View {
    let label:    String
    let isActive: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? Color.appBg : .textMuted)
                .padding(.horizontal, 14).padding(.vertical, 5)
                .background(isActive ? Color.gold : Color.clear)
                .overlay(Capsule().stroke(isActive ? Color.gold : Color.border2, lineWidth: 1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - OrdersTableHeader
struct OrdersTableHeader: View {
    var showDate: Bool = false

    var body: some View {
        HStack {
            col("Order #", width: 80)
            col("Type",    width: 100)
            col("Table",   width: 80)
            col("Items",   width: 60)
            col("Total",   flex: true)
            if showDate { col("Date", width: 90) }
            col("Time",    width: 80)
            col("Status",  width: 80)
            col("",        width: 150) // Actions column
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Color.surface2)
    }

    private func col(_ title: String, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.textFaint)
            .tracking(1).textCase(.uppercase)
            .frame(minWidth: flex ? 0 : (width ?? 0),
                   maxWidth: flex ? .infinity : width,
                   alignment: .leading)
    }
}

// MARK: - OrdersTableRow
struct OrdersTableRow: View {
    let order:    Order
    var showDate: Bool      = false
    var onDetail: (() -> Void)? = nil
    var onEdit:   (() -> Void)? = nil

    var body: some View {
        HStack {
            cell("#\(order.orderNumber)", width: 80, primary: true)
            OrderTypeBadge(type: order.type).frame(width: 100, alignment: .leading)
            cell(order.tableDisplay, width: 80)
            cell("\(order.itemCount)", width: 60)
            cell(order.total.rp, flex: true, gold: true)
            if showDate {
                cell(order.date.formatted(.dateTime.day().month(.abbreviated)), width: 90)
            }
            cell(order.date.formatted(.dateTime.hour().minute()), width: 80)
            StatusBadge(status: order.status).frame(width: 80, alignment: .leading)

            // Action buttons
            HStack(spacing: 6) {
                if let onDetail {
                    Button {
                        onDetail()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "eye").font(.system(size: 10))
                            Text("Details").font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.textMuted)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.surface3)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.border2, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                if let onEdit {
                    Button {
                        onEdit()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil").font(.system(size: 10))
                            Text("Edit").font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.gold)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.gold3.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gold3, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 150, alignment: .leading)
        }
        .padding(.horizontal, 16).padding(.vertical, 11)
    }

    private func cell(_ text: String, width: CGFloat? = nil, flex: Bool = false,
                      primary: Bool = false, gold: Bool = false) -> some View {
        Text(text)
            .font(.system(size: 13, weight: primary ? .medium : .regular))
            .foregroundColor(gold ? .gold : primary ? .textPrimary : .textMuted)
            .frame(minWidth: flex ? 0 : (width ?? 0),
                   maxWidth: flex ? .infinity : width,
                   alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    let posVM  = POSViewModel()
    let menuVM = MenuViewModel()
    let boVM   = BackOfficeViewModel()
    boVM.setup(posVM: posVM, menuVM: menuVM)
    return OrdersSection(boVM: boVM)
        .padding().background(Color.appBg)
        .environmentObject(posVM)
        .environmentObject(menuVM)
}
