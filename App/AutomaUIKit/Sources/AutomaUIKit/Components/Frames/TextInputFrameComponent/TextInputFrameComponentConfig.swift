// TextInputFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum TextInputFrameComponentVariants: String, CaseIterable {
    case generic
    case disabled
}

public class TextInputFrameComponentConfig: ObservableObject {
    @Published public var text: String
    @Published public var ghostText: String
    @Published public var icon: DesignIcons
    @Published public var hasIcon: Bool
    @Published public var backgroundColor: Color
    @Published public var textColor: Color
    @Published public var padding: EdgeInsets
    @Published public var cornerRadius: CGSize
    @Published public var variant: TextInputFrameComponentVariants

    var isDisabled: Bool {
        variant == .disabled
    }

    public init(
        text: String = "",
        ghostText: String = "Hello There!",
        icon: DesignIcons = .arrowRight,
        hasIcon: Bool = true,
        variant: TextInputFrameComponentVariants = .generic,
        backgroundColor: Color = DesignTokens.colors.primaryWhitespace2,
        textColor: Color = DesignTokens.colors.primaryText,
        padding: EdgeInsets = DesignTokens.padding.smallPaddingVar,
        cornerRadius: CGSize = DesignTokens.padding.cornerRadiusBase
    ) {
        self.text = text
        self.ghostText = ghostText
        self.icon = icon
        self.hasIcon = hasIcon
        self.variant = variant
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
}
