// Views/Components/CartRow.swift
// ─────────────────────────────────────────────
// One line in the active order panel.
// Shows item name, qty stepper, and line total.

import SwiftUI

struct CartRow: View {

    let cartItem: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 8) {

            // ── Item name ────────────────────────
            Text(cartItem.menuItem.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // ── Qty stepper ──────────────────────
            HStack(spacing: 6) {
                StepperButton(icon: "minus", action: onDecrement)

                Text("\(cartItem.quantity)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(minWidth: 20, alignment: .center)

                StepperButton(icon: "plus", action: onIncrement)
            }

            // ── Line total ───────────────────────
            Text(cartItem.lineTotal.rp)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gold)
                .frame(minWidth: 72, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
    }
}

// MARK: - Stepper button
private struct StepperButton: View {

    let icon:   String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 22, height: 22)
                .background(Color.surface3)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.border2, lineWidth: 1))
                .foregroundColor(.textMuted)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 0) {
        CartRow(
            cartItem: CartItem(menuItem: MenuItem.defaultMenu[0], quantity: 2),
            onIncrement: {},
            onDecrement: {}
        )
        Divider().background(Color.border)
        CartRow(
            cartItem: CartItem(menuItem: MenuItem.defaultMenu[1], quantity: 1),
            onIncrement: {},
            onDecrement: {}
        )
    }
    .background(Color.surface)
}
