// Views/BackOffice/BackOfficeView.swift
// ─────────────────────────────────────────────
// Root view of the Back Office screen.
// Renders a sidebar + content area.
// Creates BackOfficeViewModel locally, injecting the
// two shared VMs from the environment.

import SwiftUI

struct BackOfficeView: View {

    // MARK: - Environment

    @EnvironmentObject private var posVM:  POSViewModel
    @EnvironmentObject private var menuVM: MenuViewModel

    // MARK: - Local state

    @State private var activeSection: BOSection = .dashboard

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider().background(Color.border)
            content
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(BOSection.allCases, id: \.self) { section in
                SidebarItem(
                    section:       section,
                    activeSection: $activeSection
                )
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .frame(width: 185)
        .background(Color.surface)
    }

    // MARK: - Content area

    @ViewBuilder
    private var content: some View {
        // BackOfficeViewModel is created here, not in the App,
        // because it's only needed when this screen is visible.
        let boVM = BackOfficeViewModel(posVM: posVM, menuVM: menuVM)

        ScrollView {
            Group {
                switch activeSection {
                case .dashboard:
                    DashboardSection(boVM: boVM)
                case .orders:
                    OrdersSection(boVM: boVM)
                case .menu:
                    MenuSection()
                }
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

// MARK: - BOSection enum

enum BOSection: String, CaseIterable {
    case dashboard = "Dashboard"
    case orders    = "Orders"
    case menu      = "Menu"

    var icon: String {
        switch self {
        case .dashboard: return "chart.bar"
        case .orders:    return "list.bullet.rectangle"
        case .menu:      return "fork.knife"
        }
    }
}

// MARK: - Sidebar item

private struct SidebarItem: View {

    let section:       BOSection
    @Binding var activeSection: BOSection

    private var isActive: Bool { activeSection == section }

    var body: some View {
        Button {
            activeSection = section
        } label: {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 15))
                Text(section.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .gold : .textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isActive ? Color.surface2 : Color.clear)
            .overlay(alignment: .leading) {
                if isActive {
                    Rectangle()
                        .fill(Color.gold)
                        .frame(width: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    BackOfficeView()
        .environmentObject(POSViewModel())
        .environmentObject(MenuViewModel())
}
