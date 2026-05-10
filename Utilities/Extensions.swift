// Utilities/Extensions.swift
// ─────────────────────────────────────────────
// App-wide extensions.
// Keeps formatting logic out of Views and Models.

import SwiftUI

// MARK: - Double → Rupiah string
extension Double {

    /// Formats a Double as Indonesian Rupiah, e.g. 45000 → "Rp 45.000"
    var rp: String {
        let formatter = NumberFormatter()
        formatter.numberStyle        = .decimal
        formatter.groupingSeparator  = "."
        formatter.decimalSeparator   = ","
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "0"
        return "Rp \(formatted)"
    }
}

// MARK: - Color palette (hex initialiser + semantic tokens)
extension Color {

    // Hex initialiser — accepts "#0d0d0d" or "0d0d0d"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8)  & 0xff) / 255
        let b = Double(int & 0xff)          / 255
        self.init(red: r, green: g, blue: b)
    }

    // ── Backgrounds ───────────────────────────────
    static let appBg       = Color(hex: "#0d0d0d")
    static let surface     = Color(hex: "#171717")
    static let surface2    = Color(hex: "#1f1f1f")
    static let surface3    = Color(hex: "#2a2a2a")

    // ── Borders ───────────────────────────────────
    static let border      = Color(hex: "#2e2e2e")
    static let border2     = Color(hex: "#3a3a3a")

    // ── Text ──────────────────────────────────────
    static let textPrimary = Color(hex: "#f0ede8")
    static let textMuted   = Color(hex: "#a09890")
    static let textFaint   = Color(hex: "#6b6560")

    // ── Brand ─────────────────────────────────────
    static let gold        = Color(hex: "#c9a96e")
    static let gold2       = Color(hex: "#e8c98a")
    static let gold3       = Color(hex: "#7a5c2e")

    // ── Semantic ──────────────────────────────────
    static let success     = Color(hex: "#4caf82")
    static let successBg   = Color(hex: "#1a3a2a")
    static let danger      = Color(hex: "#e05252")
    static let dangerBg    = Color(hex: "#2a1a1a")
    static let info        = Color(hex: "#5a9fd4")
    static let infoBg      = Color(hex: "#1a2a3a")
}

// MARK: - View helpers
extension View {

    /// Applies a standard card style: surface2 background + subtle border + corner radius.
    func cardStyle(radius: CGFloat = 12) -> some View {
        self
            .background(Color.surface2)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.border, lineWidth: 1)
            )
    }
}
