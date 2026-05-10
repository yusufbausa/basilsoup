// Views/Components/Badges.swift
// ─────────────────────────────────────────────
// Small, reusable badge and chip components used
// across both POS and Back Office screens.

import SwiftUI

// MARK: - OrderTypeBadge
/// Green pill for Dine-in, blue pill for Takeaway.
struct OrderTypeBadge: View {

    let type: Order.OrderType

    private var color: Color {
        type == .dineIn ? .success : .info
    }

    var body: some View {
        Text(type.rawValue)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - StatusBadge
/// Green "Paid" badge (extendable for future statuses).
struct StatusBadge: View {

    let status: Order.OrderStatus

    private var color: Color {
        switch status {
        case .paid:     return .success
        case .refunded: return .danger
        case .edited: return .success
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - InfoChip
/// Generic coloured chip — used in CheckoutSheet for type / table.
struct InfoChip: View {

    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - StatCard
/// KPI tile used on the dashboard.
struct StatCard: View {

    let label:    String
    let value:    String
    let subLabel: String?
    let color:    Color

    init(label: String, value: String, subLabel: String? = nil, color: Color = .textPrimary) {
        self.label    = label
        self.value    = value
        self.subLabel = subLabel
        self.color    = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint)
                .tracking(1.2)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)

            if let sub = subLabel {
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundColor(.textFaint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardStyle()
    }
}

// MARK: - SummaryRow
/// Label + value row used in the order panel footer and checkout sheet.
struct SummaryRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.textMuted)
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.textMuted)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        HStack {
            OrderTypeBadge(type: .dineIn)
            OrderTypeBadge(type: .takeaway)
            StatusBadge(status: .paid)
            InfoChip(label: "Table 3", color: .success)
        }
        HStack(spacing: 12) {
            StatCard(label: "Revenue", value: "Rp 450.000", subLabel: "Today", color: .gold)
            StatCard(label: "Orders",  value: "12",          subLabel: "Today")
        }
        SummaryRow(label: "Subtotal", value: "Rp 45.000")
    }
    .padding()
    .background(Color.appBg)
}
