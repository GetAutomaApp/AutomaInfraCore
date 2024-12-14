// MACOSApp.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 700,
                    maxWidth: 700,
                    minHeight: 400,
                    maxHeight: 400
                )
        }.windowResizability(.contentSize)
    }
}
