// Utilities/Persistence.swift
// ─────────────────────────────────────────────
// Thin wrapper around UserDefaults.
// Generic so any Codable type can be saved / loaded
// without repeating encoder/decoder boilerplate in
// every ViewModel.

import Foundation

enum Persistence {

    private static let defaults = UserDefaults.standard

    // MARK: Keys
    enum Key {
        static let menu   = "bs_menu"
        static let orders = "bs_orders"
    }

    // MARK: Save
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            print("[Persistence] Failed to encode \(T.self) for key '\(key)'")
            return
        }
        defaults.set(data, forKey: key)
    }

    // MARK: Load
    static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        guard let value = try? JSONDecoder().decode(type, from: data) else {
            print("[Persistence] Failed to decode \(T.self) for key '\(key)'")
            return nil
        }
        return value
    }
}
