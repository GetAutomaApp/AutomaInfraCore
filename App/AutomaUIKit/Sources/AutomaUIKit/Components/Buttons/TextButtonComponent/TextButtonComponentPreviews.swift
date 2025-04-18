// TextButtonComponentPreviews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct TextButtonComponentPreviews: PreviewProvider {
    static var previews: some View {
        TextButtonComponentPreviewsView()
    }
}

internal struct TextButtonComponentPreviewsView: View {
    @StateObject private var sharedConfig = TextButtonComponentConfig()

    public var body: some View {
        PropertyEditor(
            object: sharedConfig,
            properties: [
                [AnyKeyPath("Is Disabled", keyPath: \.isDisabled)],
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                TextButtonComponent(config: sharedConfig, onSelfAppear: { config in
                    config.text = "0"
                }, action: { config in config.text = "\(Int(config.text)! + 1)" })
                    .contentTransition(.symbolEffect(.replace))

                EnumPropertyView(
                    value: $sharedConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )

                EnumPropertyView(
                    value: $sharedConfig.variant,
                    cases: TextButtonVariants.allCases
                )
            }
        }
    }
}
