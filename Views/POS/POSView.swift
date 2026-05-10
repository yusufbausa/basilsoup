// Views/POS/POSView.swift
// ─────────────────────────────────────────────
// Root view of the POS screen.
// Composed of:
//   • Left panel  — category tabs + scrollable menu grid
//   • Right panel — OrderPanel (cart, totals, checkout)
//
// Owns sheet/overlay presentation state.
// All business logic delegated to POSViewModel & MenuViewModel.

import SwiftUI

struct POSView: View {

    // MARK: - Environment

    @EnvironmentObject private var posVM:  POSViewModel
    @EnvironmentObject private var menuVM: MenuViewModel

    // MARK: - Local UI state

    @State private var showCheckout:    Bool  = false
    @State private var confirmedOrder:  Order? = nil
    @State private var showSuccess:     Bool  = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            menuPanel
            Divider().background(Color.border)
            OrderPanel(
                showCheckout: $showCheckout
            )
            .frame(width: 300)
        }
        // ── Checkout sheet ──────────────────────
        .sheet(isPresented: $showCheckout) {
            CheckoutSheet(isPresented: $showCheckout) {
                confirmedOrder = posVM.confirmOrder()
                showSuccess    = true
            }
        }
        // ── Success overlay ─────────────────────
        .overlay {
            if showSuccess, let order = confirmedOrder {
                SuccessOverlay(order: order) {
                    withAnimation { showSuccess = false }
                    confirmedOrder = nil
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    // MARK: - Menu panel (left side)

    private var menuPanel: some View {
        VStack(spacing: 0) {
            categoryBar
            Divider().background(Color.border)
            menuGrid
        }
        .frame(maxWidth: .infinity)
        .background(Color.appBg)
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MenuItem.allCategories, id: \.self) { cat in
                    CategoryPill(
                        label:    cat,
                        isActive: menuVM.activeCategory == cat
                    ) {
                        menuVM.activeCategory = cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.surface)
    }

    private var menuGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: 10)],
                spacing: 10
            ) {
                ForEach(menuVM.filteredMenu) { item in
                    MenuItemCard(item: item) {
                        posVM.addToCart(item)
                    }
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Preview
#Preview {
    POSView()
        .environmentObject(POSViewModel())
        .environmentObject(MenuViewModel())
}
