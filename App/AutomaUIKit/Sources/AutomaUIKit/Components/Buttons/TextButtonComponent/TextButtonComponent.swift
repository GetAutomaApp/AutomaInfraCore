// TextButtonComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The `TextButtonComponent` is a reusable component that ___

 Add a detailed description here of how to use this

 - Parameters:
     - config: The Config Used to manage state & modifications to  `TextButtonComponent`
 - Returns: some View

 To see usage examples & visuals, check out `TextButtonModifierDocumentation.md`
 */
struct TextButtonComponent: View {
    var config: TextButtonComponentConfig = .init()

    var body: some View {
        Text("Hello, TextButton!")
            .foregroundColor(config.textColor)
    }
}
