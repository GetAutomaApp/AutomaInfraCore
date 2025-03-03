// TextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public struct TextInputComponentComponent: View {
    @ObservedObject var config: TextInputComponentComponentConfig

    let onIconTap: (TextInputComponentComponentConfig) -> Void
    let onSelfAppear: (TextInputComponentComponentConfig) -> Void

    public init(
        config: TextInputComponentComponentConfig = .init(),
        onIconTap: @escaping (TextInputComponentComponentConfig) -> Void = { _ in },
        onSelfAppear: @escaping (TextInputComponentComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onIconTap = onIconTap
        self.onSelfAppear = onSelfAppear
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            TextInputFrameComponent(
                config: config,
                onIconTap: { onIconTap(config) },
                onSelfAppear: { onSelfAppear(config) }
            )

            Text("\(config.errorMessage) ")
                .fontTableFont(
                    config.titleContentFont,
                    config.errorSegmentColor
                )
        }
    }
}
