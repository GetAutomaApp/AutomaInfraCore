// AnyOrientationStackComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct AnyOrientationStackComponent_Previews: PreviewProvider {
    static var previews: some View {
        AnyOrientationStackComponentWrapperView()
    }
}

struct AnyOrientationStackComponentWrapperView: View {
    @ObservedObject var config = AnyOrientationStackComponentConfig()
    var body: some View {
        AnyOrientationStackComponent(config: config) {
            Text("HI")
            Text("HI")
        }
    }
}
