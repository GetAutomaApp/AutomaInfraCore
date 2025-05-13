// ContentView.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// A view that displays the main content of the admin interface
///
/// This view serves as the root view for the iOS admin application,
/// currently displaying a basic globe icon with styling.
struct ContentView: View {
    /// The body of the view that defines its content and layout
    public var body: some View {
        // Main vertical stack container
        VStack {
            // Globe icon with styling
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
        }
        .padding()
    }
}

/// Preview provider for ContentView
#Preview {
    ContentView()
}
