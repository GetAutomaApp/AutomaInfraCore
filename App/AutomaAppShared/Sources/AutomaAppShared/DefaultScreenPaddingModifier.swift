// DefaultScreenPaddingModifier.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct DefaultScreenPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 30)
            .padding(.vertical, 50)
    }
}

extension View {
    func defaultScreenPadding() -> some View {
        modifier(DefaultScreenPaddingModifier())
    }
}
