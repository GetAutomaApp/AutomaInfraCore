// InfoPairComponentPreviews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct InfoPairComponentPreviews: PreviewProvider {
    static var previews: some View {
        InfoPairWrapperView()
    }
}

internal struct InfoPairWrapperView: View {
    @ObservedObject public var config = InfoPairComponentConfig()

    public var body: some View {
        PropertyEditor(
            object: config,
            properties: [
                [AnyKeyPath("Title", keyPath: \.title)],
                [AnyKeyPath("Description", keyPath: \.description)],
            ]
        ) {
            VStack {
                InfoPairComponent(config: config)
                EnumPropertyView(
                    value: $config.variant,
                    cases: InfoPairVariants.allCases
                )
            }
        }
    }
}
