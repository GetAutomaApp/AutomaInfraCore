// VerificationCodeInputComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct VerificationCodeInputComponent_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeInputComponentWrapperView()
    }
}

struct VerificationCodeInputComponentWrapperView: View {
    @ObservedObject var config = VerificationCodeInputComponentConfig()
    var body: some View {
        PropertyEditor(object: config, properties: [
            [AnyKeyPath("Title", keyPath: \.title)],
            [AnyKeyPath("Error Message", keyPath: \.errorMessage)],
            [
                AnyKeyPath(
                    "TitleColor",
                    keyPath: \.titleSegmentColor
                ),
                AnyKeyPath("ErrorColor", keyPath: \.errorSegmentColor),
            ],
            [AnyKeyPath("Text", keyPath: \.text)],
            [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
            [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
            [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
            [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
            [AnyKeyPath("Text Color", keyPath: \.textColor)],
            [AnyKeyPath("Padding", keyPath: \.padding)],
            [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
        ]) {
            VerificationCodeInputComponent(config: config)

            EnumPropertyView(
                value: $config.variant,
                cases: TextInputFrameComponentVariants.allCases
            )
        }
    }
}
