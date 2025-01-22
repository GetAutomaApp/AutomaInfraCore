// TextButtonComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum TextButtonComponentVariants {
    case variant1, variant2
}

/// Add a short description here about the config
struct TextButtonComponentConfig {
    var someProperty: String = "Default Value" // Default value
    var variant: TextButtonVariants = .variant1

    let textColor: Color = .black
}
