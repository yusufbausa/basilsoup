// Views/BackOffice/MenuSection.swift

import SwiftUI

struct MenuSection: View {

    @EnvironmentObject private var menuVM: MenuViewModel

    @State private var newName:     String = ""
    @State private var newPrice:    String = ""
    @State private var newCategory: String = "Mains"
    @State private var newEmoji:    String = ""
    @State private var activeFilter: String = "All"
    @State private var showAlert:   Bool   = false
    @State private var alertMessage: String = ""

    private let categories = ["Mains", "Soup", "Sides", "Drinks", "Desserts"]

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
                FormField(label: "Name", placeholder: "e.g. Soto Ayam", text: $newName)

                FormField(label: "Price (Rp)", placeholder: "35000", text: $newPrice)
                    .frame(width: 130)

                FormField(label: "Emoji", placeholder: "🍜", text: $newEmoji)
                    .frame(width: 80)

                VStack(alignment: .leading, spacing: 5) {
                    Text("CATEGORY")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.textFaint).tracking(1)
                    Picker("", selection: $newCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu).accentColor(.gold)
                    .frame(width: 130)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(Color.surface3)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                }

                Button { submitNewItem() } label: {
                    Text("+ Add Item")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gold2)
                        .padding(.horizontal, 18).padding(.vertical, 9)
                        .background(Color.gold3.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
            }
        }
        .padding(18).cardStyle()
    }

    // MARK: - Category filter
    private var categoryFilter: some View {
        HStack(spacing: 8) {
            FilterPill(label: "All", isActive: activeFilter == "All") { activeFilter = "All" }
            ForEach(categories, id: \.self) { cat in
                FilterPill(label: cat, isActive: activeFilter == cat) { activeFilter = cat }
            }
        }
    }

    // MARK: - Menu grid
    private var filteredItems: [MenuItem] {
        activeFilter == "All" ? menuVM.menu : menuVM.menu.filter { $0.category == activeFilter }
    }

    private var menuGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 14)], spacing: 14) {
            ForEach(filteredItems) { item in
                MenuMgmtCard(item: item)
            }
        }
    }

    // MARK: - Submit
    private func submitNewItem() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { alertMessage = "Please enter an item name."; showAlert = true; return }
        guard let price = Double(newPrice), price > 0 else { alertMessage = "Please enter a valid price."; showAlert = true; return }
        menuVM.addItem(name: trimmed, price: price, category: newCategory, emoji: newEmoji)
        newName = ""; newPrice = ""; newEmoji = ""
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
                .foregroundColor(.textFaint).tracking(1)
            TextField(placeholder, text: $text)
                .font(.system(size: 13)).foregroundColor(.textPrimary).tint(.gold)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color.surface3)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - MenuMgmtCard
private struct MenuMgmtCard: View {

    @EnvironmentObject private var menuVM: MenuViewModel
    let item: MenuItem

    @State private var showDeleteConfirm = false
    @State private var showEditSheet     = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Emoji + name row
            HStack(alignment: .top) {
                Text(item.emoji).font(.system(size: 28))
                Spacer()
                // Edit button (top right)
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.gold3)
                }
                .buttonStyle(.plain)
            }

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
            Button { menuVM.toggleAvailability(of: item) } label: {
                HStack(spacing: 7) {
                    AvailabilityToggle(isOn: item.isAvailable)
                    Text(item.isAvailable ? "Available" : "Unavailable")
                        .font(.system(size: 12))
                        .foregroundColor(item.isAvailable ? .success : .textFaint)
                }
            }
            .buttonStyle(.plain).padding(.bottom, 2)

            // Action buttons row
            HStack(spacing: 8) {
                // Edit button
                Button { showEditSheet = true } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil").font(.system(size: 11))
                        Text("Edit").font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.gold)
                    .frame(maxWidth: .infinity).padding(.vertical, 7)
                    .background(Color.gold3.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gold3, lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Remove button
                Button { showDeleteConfirm = true } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "trash").font(.system(size: 11))
                        Text("Remove").font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.danger)
                    .frame(maxWidth: .infinity).padding(.vertical, 7)
                    .background(Color.dangerBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .confirmationDialog(
                    "Remove \(item.name) from the menu?",
                    isPresented: $showDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Remove", role: .destructive) { menuVM.deleteItem(item) }
                }
            }
        }
        .padding(14).cardStyle()
        .sheet(isPresented: $showEditSheet) {
            EditMenuItemSheet(isPresented: $showEditSheet, item: item)
                .environmentObject(menuVM)
        }
    }
}

// MARK: - AvailabilityToggle
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

// MARK: - EditMenuItemSheet
struct EditMenuItemSheet: View {

    @EnvironmentObject private var menuVM: MenuViewModel
    @Binding var isPresented: Bool
    let item: MenuItem

    // Editable state — seeded from item
    @State private var editName:     String
    @State private var editPrice:    String
    @State private var editCategory: String
    @State private var editEmoji:    String
    @State private var showAlert:    Bool   = false
    @State private var alertMessage: String = ""

    private let categories = ["Mains", "Soup", "Sides", "Drinks", "Desserts"]

    init(isPresented: Binding<Bool>, item: MenuItem) {
        self._isPresented = isPresented
        self.item         = item
        self._editName     = State(initialValue: item.name)
        self._editPrice    = State(initialValue: String(Int(item.price)))
        self._editCategory = State(initialValue: item.category)
        self._editEmoji    = State(initialValue: item.emoji)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button { isPresented = false } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.textMuted)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Edit Menu Item")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundColor(.gold)

                Spacer()

                Button { saveChanges() } label: {
                    Text("Save Changes")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.appBg)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(Color.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24).frame(height: 58)
            .background(Color.surface)

            Divider().background(Color.border)

            // Form content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Preview card
                    HStack(spacing: 20) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.surface2)
                                .frame(width: 90, height: 90)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.border, lineWidth: 1))
                            Text(editEmoji.isEmpty ? "🍽" : editEmoji)
                                .font(.system(size: 44))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(editName.isEmpty ? "Item Name" : editName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(editName.isEmpty ? .textFaint : .textPrimary)
                            Text(editCategory)
                                .font(.system(size: 13))
                                .foregroundColor(.textFaint)
                            Text(Double(editPrice) != nil ? (Double(editPrice)!.rp) : "Rp —")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gold)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()

                    // Edit fields
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ITEM DETAILS")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.textFaint).tracking(1.5)

                        // Name
                        editField(label: "Name") {
                            TextField("Item name", text: $editName)
                                .font(.system(size: 15)).foregroundColor(.textPrimary).tint(.gold)
                        }

                        // Price
                        editField(label: "Price (Rp)") {
                            TextField("e.g. 45000", text: $editPrice)
                                .font(.system(size: 15)).foregroundColor(.textPrimary).tint(.gold)
                            #if os(iOS)
                                .keyboardType(.numberPad)
                            #endif
                        }

                        // Emoji
                        editField(label: "Emoji") {
                            TextField("🍜", text: $editEmoji)
                                .font(.system(size: 22)).foregroundColor(.textPrimary).tint(.gold)
                        }

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CATEGORY")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.textFaint).tracking(1.5)
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    Button { editCategory = cat } label: {
                                        Text(cat)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(editCategory == cat ? Color.appBg : .textMuted)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(editCategory == cat ? Color.gold : Color.surface3)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(editCategory == cat ? Color.gold : Color.border2, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(20).cardStyle()

                    // Save button (bottom)
                    Button { saveChanges() } label: {
                        Text("Save Changes")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.appBg)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(28)
            }
            .background(Color.appBg)
        }
        .background(Color.appBg)
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Edit field helper
    private func editField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.textFaint).tracking(1.5)
            content()
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.surface3)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.border2, lineWidth: 1))
        }
    }

    // MARK: - Save
    private func saveChanges() {
        let trimmed = editName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { alertMessage = "Name cannot be empty."; showAlert = true; return }
        guard let price = Double(editPrice), price > 0 else { alertMessage = "Please enter a valid price."; showAlert = true; return }
        menuVM.updateItem(item, name: trimmed, price: price, category: editCategory, emoji: editEmoji)
        isPresented = false
    }
}

// MARK: - Preview
#Preview {
    MenuSection()
        .padding().background(Color.appBg)
        .environmentObject(MenuViewModel())
}
