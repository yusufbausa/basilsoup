// ContentView.swift
// ─────────────────────────────────────────────
// Root view. Renders the TopBar and switches between
// the POS screen and the Back Office screen.
// ViewModels are already in the environment from App.

import SwiftUI

struct ContentView: View {

    // MARK: - State

    @State private var selectedTab: AppTab = .pos

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            TopBar(selectedTab: $selectedTab)

            Divider()
                .background(Color.border)

            // Swap screens based on selected tab
            Group {
                switch selectedTab {
                case .pos:        POSView()
                case .backOffice: BackOfficeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBg)
    }
}

// MARK: - AppTab enum
// Defined here so TopBar and ContentView share the same type
// without needing a separate file.

enum AppTab: String, CaseIterable {
    case pos        = "POS"
    case backOffice = "Back Office"

    var icon: String {
        switch self {
        case .pos:        return "scroll"
        case .backOffice: return "chart.bar"
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(POSViewModel())
        .environmentObject(MenuViewModel())
}
