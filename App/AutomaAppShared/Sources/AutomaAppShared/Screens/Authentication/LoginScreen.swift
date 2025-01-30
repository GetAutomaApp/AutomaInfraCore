// LoginScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct LoginScreen: View {
    public init() {}

    public var body: some View {
        TextInputFrameComponent()
            .padding()
    }
}

#Preview {
    LoginScreen()
        .preferredColorScheme(.dark)
}
