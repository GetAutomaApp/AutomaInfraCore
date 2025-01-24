// TextInputFrameComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct TextInputFrameComponent_Previews: PreviewProvider {
    static var previews: some View {
        TextInputFrameComponentWrapperView()
            .preferredColorScheme(.dark)
    }
}

struct TextInputFrameComponentWrapperView: View {
    @ObservedObject var config = TextInputFrameComponentConfig()
    var body: some View {
        TextInputFrameComponent(config: config).padding()
    }
}
