// TextInputComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public struct TextInputComponent: View {
    @ObservedObject public var config: TextInputComponentConfig

    public let onIconTap: (TextInputComponentConfig) -> Void
    public let onSelfAppear: (TextInputComponentConfig) -> Void

    public init(
        config: TextInputComponentConfig = .init(),
        onIconTap: @escaping (TextInputComponentConfig) -> Void = { _ in },
        onSelfAppear: @escaping (TextInputComponentConfig) -> Void = { _ in }
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
