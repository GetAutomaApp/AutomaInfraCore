// InfoPairComponent.swift
// was created on 11/24/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct InfoPairComponent: View {
    @ObservedObject var config: InfoPairComponentConfig

    init(config: InfoPairComponentConfig = .init(), title: String? = nil, description: String? = nil) {
        if let title {
            config.title = title
        }

        if let description {
            config.description = description
        }

        _config = .init(initialValue: config)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(config.title)
                .fontTableFont(
                    FontTable.Headings.head4,
                    DesignTokens.colors.primaryText
                )
            Text(config.description)
                .fontTableFont(
                    FontTable.Body.body1,
                    DesignTokens.colors.secondaryText
                )
        }
    }
}
