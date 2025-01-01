// ContentView.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Test").fontTableFont(FontTable.Headings.head1)

            Text("Test").fontTableFont(FontTable.Headings.head1, .green)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
