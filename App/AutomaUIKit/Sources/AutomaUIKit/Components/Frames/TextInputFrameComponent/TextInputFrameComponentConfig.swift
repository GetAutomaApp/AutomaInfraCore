// TextInputFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum TextInputFrameComponentVariants: String, CaseIterable {
    case disabled
    case generic
}

public class TextInputFrameComponentConfig: ObservableObject {
    @Published public var text: String
    @Published public var ghostText: String
    @Published public var icon: DesignIcons
    @Published public var hasIcon: Bool
    @Published public var backgroundColor: Color
    @Published public var currentBackgroundColor: Color
    @Published public var disabledBackgroundColor: Color
    @Published public var textColor: Color
    @Published public var padding: EdgeInsets
    @Published public var cornerRadius: CGSize

    @Published public var variant: TextInputFrameComponentVariants {
        willSet {
            switch newValue {
            case .generic:
                currentBackgroundColor = backgroundColor
            case .disabled:
                currentBackgroundColor = disabledBackgroundColor
            }
        }
    }

    public var isDisabled: Bool {
        variant == .disabled
    }

    public init(
        text: String = "",
        ghostText: String = "Hello There!",
        icon: DesignIcons = .arrowRight,
        hasIcon: Bool = true,
        variant: TextInputFrameComponentVariants = .generic,
        backgroundColor: Color = DesignTokens.colors.primaryWhitespace2,
        disabledBackgroundColor: Color = DesignTokens.colors.primaryWhitespace3,
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
        self.disabledBackgroundColor = disabledBackgroundColor
        currentBackgroundColor = backgroundColor
        self.textColor = textColor
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    deinit {}
}
