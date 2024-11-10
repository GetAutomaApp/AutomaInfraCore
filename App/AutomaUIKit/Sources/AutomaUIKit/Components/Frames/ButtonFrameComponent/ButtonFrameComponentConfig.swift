// ButtonFrameComponentConfig.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp. All rights reserved.

import SwiftUI

enum ButtonFrameVariants: CaseIterable {
    case generic, disabled, rainbow
}

class ButtonFrameComponentConfig: ObservableObject {
    @Published var frameVariant: ButtonFrameVariants = .generic
    @Published var fillSpace: Bool = true
    @Published var isCircular: Bool = false

    @Published var variantGenericBackground = DesignTokens.colors.primary
    @Published var variantDisabledBackground = DesignTokens.colors.primary_whitespace_3
    @Published var defaultPadding = DesignTokens.padding.button

    @Published var roundness = DesignTokens.defaultCornerRadius
}
