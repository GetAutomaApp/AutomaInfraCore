// TextInputFrameComponentPreviews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public struct TextInputFrameComponentPreviews: PreviewProvider {
    public static var previews: some View {
        TextInputFrameComponentPropertyEditor()
    }
}

public struct TextInputFrameComponentPropertyEditor: View {
    @StateObject private var config = TextInputFrameComponentConfig()

    public var body: some View {
        PropertyEditor(
            object: config,
            properties: [
                [AnyKeyPath("Text", keyPath: \.text)],
                [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
                [AnyKeyPath("Has Icon", keyPath: \.hasIcon)],
                [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
                [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
                [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
                [AnyKeyPath("Text Color", keyPath: \.textColor)],
                [AnyKeyPath("Padding", keyPath: \.padding)],
                [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
            ]
        ) {
            VStack {
                TextInputFrameComponent(config: config)

                EnumPropertyView(
                    value: $config.variant,
                    cases: TextInputFrameComponentVariants.allCases
                )

                EnumPropertyView(
                    value: $config.icon,
                    cases: DesignIcons.allCases
                )
            }
        }
    }
}
