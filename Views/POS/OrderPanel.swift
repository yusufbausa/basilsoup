// Views/POS/OrderPanel.swift
// ─────────────────────────────────────────────
// Right-side panel of the POS screen.
// Displays the active cart, order type toggle,
// table selector, running totals, and the
// "Charge" button that triggers checkout.

import SwiftUI

struct OrderPanel: View {

    // MARK: - Dependencies

    @EnvironmentObject private var posVM: POSViewModel
    @Binding var showCheckout: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(Color.border)
            orderTypeToggle
            if posVM.orderType == .dineIn { tableSelector }
            Divider().background(Color.border)
            cartList
            Divider().background(Color.border)
            footer
        }
        .background(Color.surface)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("CURRENT ORDER")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.textMuted)
                .tracking(1.5)
            Spacer()
            Text("\(posVM.cartItemCount) items")
                .font(.system(size: 12))
                .foregroundColor(.textFaint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.surface)
    }

    private var orderTypeToggle: some View {
        HStack(spacing: 8) {
            OrderTypeButton(label: "🍽  Dine-in",   type: .dineIn)
            OrderTypeButton(label: "🥡  Takeaway",  type: .takeaway)
        }
        .padding(12)
    }

    private var tableSelector: some View {
        HStack(spacing: 10) {
            Text("Table")
                .font(.system(size: 12))
                .foregroundColor(.textFaint)

            Picker("Table", selection: $posVM.selectedTable) {
                Text("Select table…").tag("")
                ForEach(posVM.availableTables, id: \.self) { table in
                    Text(table).tag(table)
                }
            }
            .pickerStyle(.menu)
            .accentColor(.gold)
            .frame(maxWidth: .infinity)
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var cartList: some View {
        Group {
            if posVM.isCartEmpty {
                emptyCartView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(posVM.cart) { cartItem in
                            CartRow(
                                cartItem:    cartItem,
                                onIncrement: { posVM.increment(cartItem) },
                                onDecrement: { posVM.decrement(cartItem) }
                            )
                            Divider().background(Color.border)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var emptyCartView: some View {
        VStack(spacing: 8) {
            Text("🍵").font(.system(size: 40))
            Text("No items yet")
                .font(.system(size: 13))
                .foregroundColor(.textFaint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 8) {

            Divider().background(Color.border)

            HStack {
                Text("Total")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Text(posVM.cartTotal.rp)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }

            // Charge button
            Button {
                showCheckout = true
            } label: {
                Text("Charge — \(posVM.cartTotal.rp)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(posVM.isCartEmpty ? Color.gold.opacity(0.4) : Color.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(posVM.isCartEmpty)
            .buttonStyle(.plain)

            // Clear button
            Button("Clear order") {
                posVM.clearCart()
            }
            .font(.system(size: 12))
            .foregroundColor(.textFaint)
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.surface)
    }
}

// MARK: - Order type toggle button
private struct OrderTypeButton: View {

    @EnvironmentObject private var posVM: POSViewModel

    let label: String
    let type:  Order.OrderType

    private var isActive: Bool { posVM.orderType == type }

    var body: some View {
        Button {
            posVM.orderType = type
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? .textPrimary : .textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(isActive ? Color.surface3 : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.border2, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    OrderPanel(showCheckout: .constant(false))
        .frame(width: 300)
        .environmentObject(POSViewModel())
}
