// Views/BackOffice/OrderDetailSheet.swift
// ─────────────────────────────────────────────
// Full screen sheet showing complete order details.
// Includes order summary, item breakdown, and
// an Edit button that opens EditOrderSheet directly.

import SwiftUI

struct OrderDetailSheet: View {

    // MARK: - Dependencies
    @Binding var isPresented: Bool
    let order:   Order
    let posVM:   POSViewModel
    let menuVM:  MenuViewModel

    // MARK: - Local state
    @State private var showEditSheet: Bool  = false
    @State private var currentOrder:  Order        // mutable local copy

    init(isPresented: Binding<Bool>,
         order:  Order,
         posVM:  POSViewModel,
         menuVM: MenuViewModel) {
        self._isPresented  = isPresented
        self.order         = order
        self.posVM         = posVM
        self.menuVM        = menuVM
        self._currentOrder = State(initialValue: order)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider().background(Color.border)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    orderInfoCard
                    itemsCard
                    if currentOrder.wasEdited { editHistoryCard }
                }
                .padding(28)
            }
        }
        .background(Color.appBg)
        .sheet(isPresented: $showEditSheet) {
            EditOrderSheet(
                isPresented: $showEditSheet,
                order:       currentOrder,
                posVM:       posVM,
                menuVM:      menuVM
            ) {
                // Refresh local copy after edit
                if let updated = posVM.orders.first(where: { $0.id == currentOrder.id }) {
                    currentOrder = updated
                }
            }
        }
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack(alignment: .center) {
            // Close button
            Button {
                isPresented = false
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                    Text("Close")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.textMuted)
            }
            .buttonStyle(.plain)

            Spacer()

            // Title
            VStack(spacing: 2) {
                Text("Order #\(currentOrder.orderNumber)")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(.gold)
                Text(currentOrder.date.formatted(.dateTime.day().month(.wide).year().hour().minute()))
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.textFaint)
            }

            Spacer()

            // Edit button
            Button {
                showEditSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .medium))
                    Text("Edit Order")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.gold)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.gold3.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gold3, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .frame(height: 58)
        .background(Color.surface)
    }

    // MARK: - Order info card
    private var orderInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Order Information")

            HStack(spacing: 0) {
                infoCell(label: "Order #",   value: "#\(currentOrder.orderNumber)")
                Divider().background(Color.border).frame(height: 60)
                infoCell(label: "Type",      value: currentOrder.type.rawValue,
                         badge: currentOrder.type == .dineIn ? .success : .info)
                Divider().background(Color.border).frame(height: 60)
                infoCell(label: "Table",     value: currentOrder.tableDisplay)
                Divider().background(Color.border).frame(height: 60)
                infoCell(label: "Status",    value: currentOrder.status.rawValue,
                         badge: currentOrder.status == .paid ? .success :
                                currentOrder.status == .edited ? .gold : .danger)
                Divider().background(Color.border).frame(height: 60)
                infoCell(label: "Date",
                         value: currentOrder.date.formatted(.dateTime.day().month(.abbreviated).year()))
                Divider().background(Color.border).frame(height: 60)
                infoCell(label: "Time",
                         value: currentOrder.date.formatted(.dateTime.hour().minute()))
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.border, lineWidth: 1))
    }

    // MARK: - Items card
    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Items (\(currentOrder.itemCount))")

            // Column headers
            HStack {
                Text("Item")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Qty")
                    .frame(width: 50, alignment: .center)
                Text("Unit Price")
                    .frame(width: 110, alignment: .trailing)
                Text("Subtotal")
                    .frame(width: 110, alignment: .trailing)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.textFaint)
            .tracking(1)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.surface2)

            Divider().background(Color.border)

            // Item rows
            ForEach(Array(currentOrder.items.enumerated()), id: \.offset) { _, item in
                HStack {
                    Text(item.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("×\(item.quantity)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textMuted)
                        .frame(width: 50, alignment: .center)
                    Text(item.price.rp)
                        .font(.system(size: 14))
                        .foregroundColor(.textMuted)
                        .frame(width: 110, alignment: .trailing)
                    Text(item.lineTotal.rp)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gold)
                        .frame(width: 110, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 13)
                Divider().background(Color.border)
            }

            // Total row
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 40) {
                        Text("Total")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Text(currentOrder.total.rp)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gold)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.surface2)
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.border, lineWidth: 1))
    }

    // MARK: - Edit history card (only shown if order was edited)
    private var editHistoryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(title: "Edit History")
            HStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gold)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Order was edited")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textPrimary)
                    if let editDate = currentOrder.lastEditedDate {
                        Text("Last modified: \(editDate.formatted(.dateTime.day().month(.wide).year().hour().minute()))")
                            .font(.system(size: 12))
                            .foregroundColor(.textFaint)
                    }
                }
            }
            .padding(18)
        }
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.border, lineWidth: 1))
    }

    // MARK: - Helpers

    private func cardHeader(title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.textFaint)
            .tracking(1.5)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .background(Color.surface2)
            .overlay(alignment: .bottom) {
                Divider().background(Color.border)
            }
    }

    private func infoCell(label: String, value: String, badge: Color? = nil) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint)
                .tracking(1)
                .textCase(.uppercase)
            if let badgeColor = badge {
                Text(value)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(badgeColor.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview
#Preview {
    let posVM  = POSViewModel()
    let menuVM = MenuViewModel()
    let order  = Order(
        orderNumber: 1001,
        type:        .dineIn,
        table:       "Table 3",
        items:       [
            OrderLineItem(name: "Basil Soup",  price: 45000, quantity: 2),
            OrderLineItem(name: "Nasi Goreng", price: 38000, quantity: 1),
            OrderLineItem(name: "Es Teh Manis",price: 12000, quantity: 3),
        ],
        subtotal: 167000, tax: 0, total: 167000
    )
    OrderDetailSheet(isPresented: .constant(true), order: order, posVM: posVM, menuVM: menuVM)
}
