// TextInputFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum TextInputFrameComponentVariants {
    case generic
}

public class TextInputFrameComponentConfig: ObservableObject {
    @Published public var text: String
    @Published public var ghostText: String
    @Published public var icon: DesignIcons
    @Published public var hasIcon: Bool

    public var variant: TextInputFrameComponentVariants

    public init(
        text: String = "",
        ghostText: String = "Hello There!",
        icon: DesignIcons = .arrowRight,
        hasIcon: Bool = true,
        variant: TextInputFrameComponentVariants = .generic
    ) {
        self.text = text
        self.ghostText = ghostText
        self.icon = icon
        self.hasIcon = hasIcon
        self.variant = variant
    }
}
