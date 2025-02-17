// PhoneNumberTextInputComponent_Previews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// Add a preview per state difference (No need to add all states)

struct PhoneNumberTextInputComponent_Previews: PreviewProvider {
    static var previews: some View {
        PhoneNumberTextInputComponentWrapperView()
    }
}

struct PhoneNumberTextInputComponentWrapperView: View {
    var body: some View {
//        PropertyEditor(
//            object: config,
//            properties: [
//                [AnyKeyPath("Title", keyPath: \.title)],
//                [AnyKeyPath("Error Message", keyPath: \.errorMessage)],
//                [
//                    AnyKeyPath(
//                        "TitleColor",
//                        keyPath: \.titleSegmentColor
//                    ),
//                    AnyKeyPath("ErrorColor", keyPath: \.errorSegmentColor),
//                ],
//                [AnyKeyPath("Text", keyPath: \.text)],
//                [AnyKeyPath("Ghost Text", keyPath: \.ghostText)],
//                [AnyKeyPath("Has Icon", keyPath: \.hasIcon)],
//                [AnyKeyPath("Background Color", keyPath: \.backgroundColor)],
//                [AnyKeyPath("Disabled Background Color", keyPath: \.disabledBackgroundColor)],
//                [AnyKeyPath("Current Background Color", keyPath: \.currentBackgroundColor)],
//                [AnyKeyPath("Text Color", keyPath: \.textColor)],
//                [AnyKeyPath("Padding", keyPath: \.padding)],
//                [AnyKeyPath("Corner Radius", keyPath: \.cornerRadius)],
//            ]
//        ) {
//            VStack {
//                PhoneNumberTextInputComponent(config: config)
//
//                EnumPropertyView(
//                    value: $config.variant,
//                    cases: TextInputFrameComponentVariants.allCases
//                )
//
//                EnumPropertyView(
//                    value: $config.icon,
//                    cases: DesignIcons.allCases
//                )
//            }

        PhoneNumberTextInputComponent().padding().preferredColorScheme(.dark)
    }
}
