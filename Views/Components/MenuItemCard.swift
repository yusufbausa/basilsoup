// Views/Components/MenuItemCard.swift
// ─────────────────────────────────────────────
// Tappable card in the POS menu grid.
// Dims itself when the item is unavailable.

import SwiftUI

struct MenuItemCard: View {

    let item:   MenuItem
    let onTap:  () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(item.emoji)
                    .font(.system(size: 28))

                Text(item.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(item.price.rp)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gold)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.surface2)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // Visual feedback
            .opacity(item.isAvailable ? 1.0 : 0.35)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!item.isAvailable)
        // Track press state for scale feedback
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true  }
                .onEnded   { _ in isPressed = false }
        )
    }
}

// MARK: - Preview
#Preview {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
        MenuItemCard(item: MenuItem.defaultMenu[0]) {}
        MenuItemCard(item: MenuItem(name: "Unavailable", price: 20000, category: "Sides", emoji: "🚫", isAvailable: false)) {}
    }
    .padding()
    .background(Color.appBg)
}
