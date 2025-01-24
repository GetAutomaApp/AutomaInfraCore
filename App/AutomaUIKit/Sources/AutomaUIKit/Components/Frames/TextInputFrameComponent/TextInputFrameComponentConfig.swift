// TextInputFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum TextInputFrameComponentVariants {
    case variant1, variant2
}

/// Add a short description here about the config
class TextInputFrameComponentConfig: ObservableObject {
    @State var text: String = "default-value" // Default value
    var variant: TextInputFrameComponentVariants = .variant1

    let textColor: Color = .black
}
