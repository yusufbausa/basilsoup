// Views/POS/CheckoutSheet.swift
// ─────────────────────────────────────────────
// Modal sheet presented when the cashier taps "Charge".
// Shows an order summary and a confirm button.
// SuccessOverlay is shown after payment is confirmed.

import SwiftUI

// MARK: - CheckoutSheet

struct CheckoutSheet: View {

    // MARK: - Dependencies

    @EnvironmentObject private var posVM: POSViewModel
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            Divider().background(Color.border)
            orderSummary
            Divider().background(Color.border)
            actionButtons
        }
        .background(Color.surface)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    private var sheetHeader: some View {
        HStack {
            Text("Confirm Payment")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(.gold)
            Spacer()
            Button {
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.textFaint)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
    }

    private var orderSummary: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Order type + table chips
                HStack(spacing: 10) {
                    InfoChip(label: posVM.orderType.rawValue, color: .info)
                    if posVM.orderType == .dineIn, !posVM.selectedTable.isEmpty {
                        InfoChip(label: posVM.selectedTable, color: .success)
                    }
                }

                // Line items
                VStack(spacing: 0) {
                    ForEach(posVM.cart) { item in
                        HStack {
                            Text("\(item.menuItem.emoji) \(item.menuItem.name)")
                                .font(.system(size: 14))
                                .foregroundColor(.textPrimary)
                            Spacer()
                            Text("×\(item.quantity)")
                                .font(.system(size: 13))
                                .foregroundColor(.textFaint)
                            Text(item.lineTotal.rp)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gold)
                                .frame(minWidth: 90, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                        Divider().background(Color.border)
                    }
                }

                // Totals
                VStack(spacing: 8) {
                    SummaryRow(label: "Subtotal",  value: posVM.cartSubtotal.rp)
                    SummaryRow(label: "Tax (10%)", value: posVM.cartTax.rp)
                    Divider().background(Color.border)
                    HStack {
                        Text("Total")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text(posVM.cartTotal.rp)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.gold)
                    }
                }
            }
            .padding(24)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Cancel
            Button("Cancel") {
                isPresented = false
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.surface2)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.border2, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .buttonStyle(.plain)

            // Confirm
            Button("Confirm Payment") {
                isPresented = false
                onConfirm()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.appBg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.gold)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .buttonStyle(.plain)
        }
        .padding(24)
    }
}

// MARK: - SuccessOverlay

struct SuccessOverlay: View {

    let order:   Order
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            // Card
            VStack(spacing: 20) {
                Text("✅")
                    .font(.system(size: 60))

                Text("Order #\(order.orderNumber) Confirmed!")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(.gold)
                    .multilineTextAlignment(.center)

                Text(order.total.rp)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.textPrimary)

                Button("New Order") {
                    onDismiss()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.appBg)
                .padding(.horizontal, 44)
                .padding(.vertical, 14)
                .background(Color.gold)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .buttonStyle(.plain)
            }
            .padding(44)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.4), radius: 30)
        }
    }
}

// MARK: - Preview
#Preview("Checkout Sheet") {
    CheckoutSheet(isPresented: .constant(true), onConfirm: {})
        .environmentObject(POSViewModel())
}
