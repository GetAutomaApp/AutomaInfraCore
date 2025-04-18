// InfoPairComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The `InfoPairComponent` is a UI element that renders a title + subtext.

 The component can be used for the following:
 - To render out a title + description information for onboarding screens
 - To render a title & subtext component for a description page

 For more information on how to use this, take a look at `InfoPairComponentDocumentation.md`
 */
public struct InfoPairComponent: View {
    @ObservedObject public var config: InfoPairComponentConfig

    public let onSelfAppear: (InfoPairComponentConfig) -> Void

    public init(
        config: InfoPairComponentConfig = .init(),
        onSelfAppear: @escaping (InfoPairComponentConfig) -> Void = { _ in }
    ) {
        _config = .init(initialValue: config)

        self.onSelfAppear = onSelfAppear
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(config.title)
                .fontTableFont(
                    FontTable.Crimson.Headings.head4,
                    DesignTokens.colors.primaryText
                ).tag("title")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(config.description)
                .fontTableFont(
                    FontTable.Crimson.Body.body1,
                    DesignTokens.colors.secondaryText
                ).tag("description")
                .lineLimit(3)
                .minimumScaleFactor(0.5)
        }.onAppear {
            onSelfAppear(config)
        }
    }
}
