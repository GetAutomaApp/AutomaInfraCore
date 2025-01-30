// TextInputFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum TextInputFrameComponentVariants {
    case variant1, variant2
}

class TextInputFrameComponentConfig: ObservableObject {
    @Published var text: String = ""
    @Published var ghostText: String = "Hello There!"
    @Published var icon: DesignIcons = .arrowRight
    @Published var hasIcon: Bool = true

    var variant: TextInputFrameComponentVariants = .variant1

    let textColor: Color = .black
}
