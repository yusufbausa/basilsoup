// Views/POS/EditOrderSheet.swift

import SwiftUI

struct EditOrderSheet: View {

    // MARK: - Dependencies (passed directly, not via environment)
    @Binding var isPresented: Bool
    let order:    Order
    let posVM:    POSViewModel
    let menuVM:   MenuViewModel
    let onSave:   () -> Void

    // MARK: - Local edit state
    @State private var editItems:      [OrderLineItem]
    @State private var editType:       Order.OrderType
    @State private var editTable:      String
    @State private var activeCategory: String = "All"
    @State private var showConfirm:    Bool   = false

    init(isPresented: Binding<Bool>,
         order:   Order,
         posVM:   POSViewModel,
         menuVM:  MenuViewModel,
         onSave:  @escaping () -> Void) {
        self._isPresented = isPresented
        self.order        = order
        self.posVM        = posVM
        self.menuVM       = menuVM
        self.onSave       = onSave
        self._editItems   = State(initialValue: order.items)
        self._editType    = State(initialValue: order.type)
        self._editTable   = State(initialValue: order.table ?? "")
    }

    // MARK: - Computed totals
    private var subtotal: Double { editItems.reduce(0) { $0 + $1.lineTotal } }
    private var total:    Double { subtotal }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            menuPickerPanel
            Divider().background(Color.border)
            editPanel
        }
        .background(Color.appBg)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationSizing(.fitted)
        .frame(minWidth: 900, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
        .interactiveDismissDisabled()
        .confirmationDialog(
            "Save changes to Order #\(order.orderNumber)?",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            Button("Save Changes") { saveAndClose() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Left: menu picker
    private var menuPickerPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ADD ITEMS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textMuted)
                    .tracking(1.5)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.surface)

            Divider().background(Color.border)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MenuItem.allCategories, id: \.self) { cat in
                        CategoryPill(label: cat, isActive: activeCategory == cat) {
                            activeCategory = cat
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
            }
            .background(Color.surface)

            Divider().background(Color.border)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                    ForEach(filteredMenu) { item in
                        MenuItemCard(item: item) { addItem(item) }
                    }
                }
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var filteredMenu: [MenuItem] {
        let available = menuVM.menu.filter(\.isAvailable)
        guard activeCategory != "All" else { return available }
        return available.filter { $0.category == activeCategory }
    }

    // MARK: - Right: edit panel
    private var editPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("EDITING ORDER #\(order.orderNumber)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gold).tracking(1.2)
                    if order.wasEdited {
                        Text("Previously edited")
                            .font(.system(size: 10)).foregroundColor(.textFaint)
                    }
                }
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20)).foregroundColor(.textFaint)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.surface)

            Divider().background(Color.border)

            // Order type toggle
            HStack(spacing: 8) {
                editTypeButton(label: "🍽  Dine-in",  type: .dineIn)
                editTypeButton(label: "🥡  Takeaway", type: .takeaway)
            }
            .padding(12)

            // Table selector
            if editType == .dineIn {
                HStack(spacing: 10) {
                    Text("Table").font(.system(size: 12)).foregroundColor(.textFaint)
                    Picker("Table", selection: $editTable) {
                        Text("Select table…").tag("")
                        ForEach(posVM.availableTables, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu).accentColor(.gold)
                    .frame(maxWidth: .infinity)
                    .background(Color.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 14).padding(.bottom, 8)
            }

            Divider().background(Color.border)

            // Item list
            if editItems.isEmpty {
                VStack(spacing: 8) {
                    Text("🍵").font(.system(size: 36))
                    Text("No items — add from the menu")
                        .font(.system(size: 13)).foregroundColor(.textFaint)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(editItems.enumerated()), id: \.offset) { idx, item in
                            EditItemRow(
                                item:        item,
                                onIncrement: { incrementItem(at: idx) },
                                onDecrement: { decrementItem(at: idx) }
                            )
                            Divider().background(Color.border)
                        }
                    }
                }
            }

            Divider().background(Color.border)

            // Footer
            VStack(spacing: 8) {
                HStack {
                    Text("Total")
                        .font(.system(size: 17, weight: .semibold)).foregroundColor(.textPrimary)
                    Spacer()
                    Text(total.rp)
                        .font(.system(size: 17, weight: .semibold)).foregroundColor(.textPrimary)
                }

                Button { showConfirm = true } label: {
                    Text("Save Changes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.appBg)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(editItems.isEmpty ? Color.gold.opacity(0.4) : Color.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(editItems.isEmpty).buttonStyle(.plain)

                Button("Discard Changes") { isPresented = false }
                    .font(.system(size: 12)).foregroundColor(.textFaint).buttonStyle(.plain)
            }
            .padding(14).background(Color.surface)
        }
        .frame(width: 380).background(Color.surface)
    }

    private func editTypeButton(label: String, type: Order.OrderType) -> some View {
        Button { editType = type } label: {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(editType == type ? .textPrimary : .textMuted)
                .frame(maxWidth: .infinity).padding(.vertical, 7)
                .background(editType == type ? Color.surface3 : Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.border2, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Item mutations
    private func addItem(_ menuItem: MenuItem) {
        if let idx = editItems.firstIndex(where: { $0.name == menuItem.name }) {
            editItems[idx].quantity += 1
        } else {
            editItems.append(OrderLineItem(name: menuItem.name, price: menuItem.price, quantity: 1))
        }
    }

    private func incrementItem(at index: Int) {
        guard index < editItems.count else { return }
        editItems[index].quantity += 1
    }

    private func decrementItem(at index: Int) {
        guard index < editItems.count else { return }
        if editItems[index].quantity > 1 { editItems[index].quantity -= 1 }
        else { editItems.remove(at: index) }
    }

    private func saveAndClose() {
        posVM.updateOrder(order, items: editItems, type: editType, table: editTable)
        isPresented = false
        onSave()
    }
}

// MARK: - Edit item row
private struct EditItemRow: View {
    let item:        OrderLineItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(item.name)
                .font(.system(size: 13, weight: .medium)).foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Button(action: onDecrement) {
                    Image(systemName: item.quantity == 1 ? "trash" : "minus")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                        .background(item.quantity == 1 ? Color.dangerBg : Color.surface3)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(item.quantity == 1 ? Color.danger : Color.border2, lineWidth: 1))
                        .foregroundColor(item.quantity == 1 ? .danger : .textMuted)
                }
                .buttonStyle(.plain)

                Text("\(item.quantity)")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(.textPrimary)
                    .frame(minWidth: 20, alignment: .center)

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                        .background(Color.surface3).clipShape(Circle())
                        .overlay(Circle().stroke(Color.border2, lineWidth: 1))
                        .foregroundColor(.textMuted)
                }
                .buttonStyle(.plain)
            }

            Text(item.lineTotal.rp)
                .font(.system(size: 13, weight: .medium)).foregroundColor(.gold)
                .frame(minWidth: 72, alignment: .trailing)
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
    }
}
