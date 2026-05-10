// Views/Components/CategoryPill.swift
// ─────────────────────────────────────────────
// Tappable pill used in the POS category filter bar.

import SwiftUI

struct CategoryPill: View {

    let label:    String
    let isActive: Bool
    let action:   () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? Color.appBg : .textMuted)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isActive ? Color.gold : Color.clear)
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color.gold : Color.border2, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HStack {
        CategoryPill(label: "All",   isActive: true)  {}
        CategoryPill(label: "Soup",  isActive: false) {}
        CategoryPill(label: "Mains", isActive: false) {}
    }
    .padding()
    .background(Color.appBg)
}
