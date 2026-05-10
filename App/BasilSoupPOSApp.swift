// App/BasilSoupPOSApp.swift
// ─────────────────────────────────────────────
// @main entry point. Injects the shared POSViewModel
// and MenuViewModel into the environment so all child
// views can access them without prop-drilling.

import SwiftUI

@main
struct BasilSoupPOSApp: App {

    // One shared instance of each ViewModel lives here
    // and flows down the view hierarchy via @EnvironmentObject.
    @StateObject private var posVM  = POSViewModel()
    @StateObject private var menuVM = MenuViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(posVM)
                .environmentObject(menuVM)
                .preferredColorScheme(.dark)
        }
    }
}
