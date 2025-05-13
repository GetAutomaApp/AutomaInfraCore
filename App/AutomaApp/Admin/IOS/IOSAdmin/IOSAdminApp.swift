// IOSAdminApp.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// The main entry point for the iOS admin application
///
/// This app structure serves as the root of the application, configuring the main window
/// and establishing the dark color scheme as the default appearance.
@main
struct IOSAdminApp: App {
    /// The body of the app that defines its scene structure
    ///
    /// Creates a window group containing the main ContentView with dark mode enabled
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
