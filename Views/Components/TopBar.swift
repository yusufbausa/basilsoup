// Views/Components/TopBar.swift
// ─────────────────────────────────────────────
// Sticky top navigation bar.
// Shows the logo, tab switcher, and a live clock.

import SwiftUI
import Combine

struct TopBar: View {

    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            // ── Logo ─────────────────────────────
            LogoView()

            Spacer()

            // ── Tab switcher ─────────────────────
            HStack(spacing: 4) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabPillButton(tab: tab, selectedTab: $selectedTab)
                }
            }

            Spacer()

            // ── Clock ─────────────────────────────
            LiveClockView()
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .background(Color.surface)
    }
}

// MARK: - Logo
private struct LogoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Basil Soup")
                .font(.system(size: 21, weight: .semibold, design: .serif))
                .foregroundColor(.gold)
//            Text("RESTAURANT POS")
//                .font(.system(size: 9, weight: .light))
//                .foregroundColor(.textFaint)
//                .tracking(2.5)
        }
    }
}

// MARK: - Tab pill button
private struct TabPillButton: View {

    let tab: AppTab
    @Binding var selectedTab: AppTab

    private var isActive: Bool { selectedTab == tab }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                Text(tab.rawValue)
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(isActive ? .gold2 : .textMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isActive ? Color.gold3.opacity(0.6) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Live clock
private struct LiveClockView: View {

    @State private var now = Date()

    // Timer fires every second on the main run loop
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(now, style: .time)
            .font(.system(size: 12, weight: .light, design: .monospaced))
            .foregroundColor(.textFaint)
            .onReceive(timer) { now = $0 }
    }
}

// MARK: - Preview
#Preview {
    TopBar(selectedTab: .constant(.pos))
        .frame(height: 56)
}
