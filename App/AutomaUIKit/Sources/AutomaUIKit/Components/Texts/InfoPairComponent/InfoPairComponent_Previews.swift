// InfoPairComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct InfoPairComponent_Previews: PreviewProvider {
    static var previews: some View {
        InfoPairWrapperView()
    }
}

struct InfoPairWrapperView: View {
    @ObservedObject var config = InfoPairComponentConfig()

    var body: some View {
        PropertyEditor(
            object: config,
            properties: [
                [AnyKeyPath("Title", keyPath: \.title)],
                [AnyKeyPath("Description", keyPath: \.description)],
            ],
            viewer: {
                VStack {
                    InfoPairComponent(config: config)
                    EnumPropertyView(
                        value: $config.variant,
                        cases: InfoPairVariants.allCases
                    )
                }
            }
        )
    }
}
