// Views/BackOffice/BackOfficeView.swift

import SwiftUI

struct BackOfficeView: View {

    @EnvironmentObject private var posVM:  POSViewModel
    @EnvironmentObject private var menuVM: MenuViewModel

    @State private var activeSection: BOSection = .dashboard

    // BackOfficeViewModel held as @StateObject so it's
    // NOT recreated on every redraw
    @StateObject private var boVM = BackOfficeViewModel()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider().background(Color.border)
            content
        }
        .onAppear {
            boVM.setup(posVM: posVM, menuVM: menuVM)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(BOSection.allCases, id: \.self) { section in
                SidebarItem(section: section, activeSection: $activeSection)
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .frame(width: 185)
        .background(Color.surface)
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            Group {
                switch activeSection {
                case .dashboard: DashboardSection(boVM: boVM)
                case .orders:    OrdersSection(boVM: boVM)
                case .menu:      MenuSection()
                }
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

// MARK: - BOSection
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
    let section: BOSection
    @Binding var activeSection: BOSection

    private var isActive: Bool { activeSection == section }

    var body: some View {
        Button {
            activeSection = section
        } label: {
            HStack(spacing: 10) {
                Image(systemName: section.icon).font(.system(size: 15))
                Text(section.rawValue).font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isActive ? .gold : .textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(isActive ? Color.surface2 : Color.clear)
            .overlay(alignment: .leading) {
                if isActive { Rectangle().fill(Color.gold).frame(width: 2) }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BackOfficeView()
        .environmentObject(POSViewModel())
        .environmentObject(MenuViewModel())
}
