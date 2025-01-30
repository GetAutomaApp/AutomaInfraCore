// TextInputFrameComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The `TextInputFrameComponent` is a reusable component that ___

 Add a detailed description here of how to use this

 - Parameters:
     - config: The Config Used to manage state & modifications to  `TextInputFrameComponent`
 - Returns: some View

 To see usage examples & visuals, check out `TextInputFrameModifierDocumentation.md`
 */
public struct TextInputFrameComponent: View {
    @ObservedObject public var config: TextInputFrameComponentConfig

    public init(config: TextInputFrameComponentConfig = .init()) {
        self.config = config
    }

    public var body: some View {
        HStack {
            if config.hasIcon {
                config.icon.image
                    .foregroundStyle(DesignTokens.colors.primaryText)
            }
            TextField(config.ghostText, text: $config.text)
        }
        .padding(DesignTokens.padding.smallPaddingVar)
        .background(DesignTokens.colors.primaryWhitespace2)
        .clipShape(
            RoundedRectangle(
                cornerSize: DesignTokens.padding.cornerRadiusBase
            )
        )
    }
}
