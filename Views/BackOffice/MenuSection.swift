// Views/BackOffice/MenuSection.swift
// ─────────────────────────────────────────────
// Back Office → Menu tab.
// Lets staff add new menu items and manage
// existing ones (toggle availability / delete).

import SwiftUI

struct MenuSection: View {

    // MARK: - Environment

    @EnvironmentObject private var menuVM: MenuViewModel

    // MARK: - Local form state

    @State private var newName:     String = ""
    @State private var newPrice:    String = ""
    @State private var newCategory: String = "Mains"
    @State private var newEmoji:    String = ""
    @State private var activeFilter:String = "All"
    @State private var showAlert:   Bool   = false
    @State private var alertMessage:String = ""

    private let categories = ["Mains", "Soup", "Sides", "Drinks", "Desserts"]

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text("Menu Management")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundColor(.gold)

            addItemForm
            categoryFilter
            menuGrid
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Add item form

    private var addItemForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Add new item")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textMuted)

            HStack(spacing: 12) {
                // Name field (flex)
                FormField(label: "Name", placeholder: "e.g. Soto Ayam", text: $newName)

                // Price field
                FormField(label: "Price (Rp)", placeholder: "35000", text: $newPrice)
                    .frame(width: 130)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif

                // Emoji field
                FormField(label: "Emoji", placeholder: "🍜", text: $newEmoji)
                    .frame(width: 80)

                // Category picker
                VStack(alignment: .leading, spacing: 5) {
                    Text("CATEGORY")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textFaint)
                        .tracking(1)

                    Picker("", selection: $newCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                    .accentColor(.gold)
                    .frame(width: 130)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.surface3)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.border2, lineWidth: 1)
                    )
                }

                // Submit button
                Button {
                    submitNewItem()
                } label: {
                    Text("+ Add Item")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gold2)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Color.gold3.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.top, 16) // align with fields
            }
        }
        .padding(18)
        .cardStyle()
    }

    // MARK: - Category filter bar

    private var categoryFilter: some View {
        HStack(spacing: 8) {
            FilterPill(label: "All", isActive: activeFilter == "All") {
                activeFilter = "All"
            }
            ForEach(categories, id: \.self) { cat in
                FilterPill(label: cat, isActive: activeFilter == cat) {
                    activeFilter = cat
                }
            }
        }
    }

    // MARK: - Menu grid

    private var filteredItems: [MenuItem] {
        activeFilter == "All"
            ? menuVM.menu
            : menuVM.menu.filter { $0.category == activeFilter }
    }

    private var menuGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 200), spacing: 14)],
            spacing: 14
        ) {
            ForEach(filteredItems) { item in
                MenuMgmtCard(item: item)
            }
        }
    }

    // MARK: - Form submission

    private func submitNewItem() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            alertMessage = "Please enter an item name."
            showAlert    = true
            return
        }
        guard let price = Double(newPrice), price > 0 else {
            alertMessage = "Please enter a valid price."
            showAlert    = true
            return
        }

        menuVM.addItem(
            name:     trimmedName,
            price:    price,
            category: newCategory,
            emoji:    newEmoji
        )

        // Reset form
        newName  = ""
        newPrice = ""
        newEmoji = ""
    }
}

// MARK: - FormField

private struct FormField: View {

    let label:       String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint)
                .tracking(1)

            TextField(placeholder, text: $text)
                .font(.system(size: 13))
                .foregroundColor(.textPrimary)
                .tint(.gold)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.surface3)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.border2, lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - MenuMgmtCard

private struct MenuMgmtCard: View {

    @EnvironmentObject private var menuVM: MenuViewModel

    let item: MenuItem
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.emoji)
                .font(.system(size: 28))

            Text(item.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)

            Text(item.category)
                .font(.system(size: 11))
                .foregroundColor(.textFaint)

            Text(item.price.rp)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.gold)
                .padding(.bottom, 4)

            // Availability toggle
            Button {
                menuVM.toggleAvailability(of: item)
            } label: {
                HStack(spacing: 7) {
                    AvailabilityToggle(isOn: item.isAvailable)
                    Text(item.isAvailable ? "Available" : "Unavailable")
                        .font(.system(size: 12))
                        .foregroundColor(item.isAvailable ? .success : .textFaint)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 2)

            // Delete button
            Button {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                    Text("Remove")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.danger)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.dangerBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Remove \(item.name) from the menu?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    menuVM.deleteItem(item)
                }
            }
        }
        .padding(14)
        .cardStyle()
    }
}

// MARK: - Availability toggle indicator

private struct AvailabilityToggle: View {

    let isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Color.success : Color.surface3)
                .frame(width: 30, height: 17)
                .overlay(Capsule().stroke(isOn ? Color.success : Color.border2, lineWidth: 1))
            Circle()
                .fill(isOn ? Color.white : Color.textFaint)
                .frame(width: 11, height: 11)
                .padding(.horizontal, 2)
        }
        .animation(.easeInOut(duration: 0.18), value: isOn)
    }
}

// MARK: - Preview
#Preview {
    MenuSection()
        .padding()
        .background(Color.appBg)
        .environmentObject(MenuViewModel())
}
