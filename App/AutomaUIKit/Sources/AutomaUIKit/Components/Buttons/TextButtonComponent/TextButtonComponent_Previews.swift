// TextButtonComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct TextButtonComponent_Previews: PreviewProvider {
    static var previews: some View {
        TextButtonComponentWrapperView()
    }
}

struct TextButtonComponentWrapperView: View {
    @ObservedObject var config = TextButtonComponentConfig()
    var body: some View {
        TextButtonComponent(config: config).padding()
    }
}
