// Models/MenuItem.swift
// ─────────────────────────────────────────────
// Pure data model — no business logic here.
// Codable so it can be saved to / loaded from UserDefaults.
// Identifiable so SwiftUI ForEach works without manual id:.

import Foundation

struct MenuItem: Identifiable, Codable, Equatable, Hashable {

    var id:          UUID    = UUID()
    var name:        String
    var price:       Double
    var category:    String
    var emoji:       String
    var isAvailable: Bool    = true

    // All categories used across the app
    static let allCategories = ["All", "Soup", "Mains", "Sides", "Drinks", "Desserts"]

    // Default seed data shown on first launch
    static let defaultMenu: [MenuItem] = [
        MenuItem(name: "Basil Soup",    price: 45_000, category: "Soup",     emoji: "🍵"),
        MenuItem(name: "Nasi Goreng",   price: 38_000, category: "Mains",    emoji: "🍳"),
        MenuItem(name: "Ayam Bakar",    price: 52_000, category: "Mains",    emoji: "🍗"),
        MenuItem(name: "Gado-Gado",     price: 30_000, category: "Sides",    emoji: "🥗"),
        MenuItem(name: "Es Teh Manis",  price: 12_000, category: "Drinks",   emoji: "🧋"),
        MenuItem(name: "Jus Alpukat",   price: 18_000, category: "Drinks",   emoji: "🥤"),
        MenuItem(name: "Tempe Goreng",  price: 20_000, category: "Sides",    emoji: "🍱"),
        MenuItem(name: "Soto Ayam",     price: 40_000, category: "Soup",     emoji: "🥣"),
        MenuItem(name: "Es Krim",       price: 22_000, category: "Desserts", emoji: "🍨"),
        MenuItem(name: "Mie Goreng",    price: 36_000, category: "Mains",    emoji: "🍜"),
        MenuItem(name: "Air Mineral",   price:  8_000, category: "Drinks",   emoji: "💧"),
        MenuItem(name: "Pisang Goreng", price: 18_000, category: "Desserts", emoji: "🍌"),
    ]
}
