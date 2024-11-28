// InfoPairComponent.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
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
struct InfoPairComponent: View {
    @ObservedObject var config: InfoPairComponentConfig

    let onSelfAppear: (InfoPairComponentConfig) -> Void

    init(
        config: InfoPairComponentConfig = .init(),
        title: String? = nil,
        description: String? = nil,
        onSelfAppear: @escaping (InfoPairComponentConfig) -> Void = { _ in }
    ) {
        if let title {
            config.title = title
        }

        if let description {
            config.description = description
        }

        _config = .init(initialValue: config)

        self.onSelfAppear = onSelfAppear
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(config.title)
                .fontTableFont(
                    FontTable.Headings.head4,
                    DesignTokens.colors.primaryText
                ).tag("title")
            Text(config.description)
                .fontTableFont(
                    FontTable.Body.body1,
                    DesignTokens.colors.secondaryText
                ).tag("description")
        }.onAppear {
            onSelfAppear(config)
        }
    }
}
