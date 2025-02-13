// TextInputComponentComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct TextInputComponentComponent: View {
    @ObservedObject var config: TextInputComponentComponentConfig = .init()

    var body: some View {
        VStack(alignment: .leading) {
            if !config.title.isEmpty {
                Text(config.title)
                    .fontTableFont(config.titleContentFont, config.titleSegmentColor)
            }

            TextInputFrameComponent(config: config)

            if !config.errorMessage.isEmpty {
                Text(config.errorMessage)
                    .fontTableFont(
                        config.titleContentFont,
                        config.errorSegmentColor
                    )
            }
        }
    }
}
