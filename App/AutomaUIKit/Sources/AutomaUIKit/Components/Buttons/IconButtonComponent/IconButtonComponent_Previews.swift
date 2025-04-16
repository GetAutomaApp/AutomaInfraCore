// IconButtonComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct IconButtonComponent_Previews: PreviewProvider {
    static var previews: some View {
        IconButtonComponent_PreviewsView()
    }
}

internal struct IconButtonComponent_PreviewsView: View {
    @StateObject private var sharedConfig = IconButtonComponentConfig()

    public var body: some View {
        PropertyEditor(
            object: sharedConfig,
            properties: [
                [AnyKeyPath("Is Disabled", keyPath: \.isDisabled)],
                [AnyKeyPath("Is Loading", keyPath: \.isLoading)],
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                HStack {
                    IconButtonComponent(config: sharedConfig, onSelfAppear: { config in
                        config.icon = .play
                    }, configAction: { config in
                        if config.icon == .play {
                            config.icon = .pause
                        } else {
                            config.icon = .play
                        }
                    }).contentTransition(.symbolEffect(.replace))
                }

                EnumPropertyView(
                    value: $sharedConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )

                EnumPropertyView(
                    value: $sharedConfig.variant,
                    cases: IconButtonVariants.allCases
                )
            }
        }
    }
}
