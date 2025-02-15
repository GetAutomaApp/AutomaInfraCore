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

    let onIconTap: () -> Void
    let onSelfAppear: () -> Void

    public init(
        config: TextInputFrameComponentConfig = .init(),
        onIconTap: @escaping () -> Void = {},
        onSelfAppear: @escaping () -> Void = {}
    ) {
        self.config = config
        self.onIconTap = onIconTap
        self.onSelfAppear = onSelfAppear
    }

    public var body: some View {
        HStack {
            if config.hasIcon {
                config.icon.image
                    .foregroundStyle(config.textColor)
                    .onTapGesture {
                        onIconTap()
                    }
            }
            TextField(config.ghostText, text: $config.text)
                .disabled(config.isDisabled)
        }
        .padding(config.padding)
        .background(
            config.currentBackgroundColor
        )
        .clipShape(
            RoundedRectangle(
                cornerSize: config.cornerRadius
            )
        )
        .onAppear(perform: onSelfAppear)
    }
}
