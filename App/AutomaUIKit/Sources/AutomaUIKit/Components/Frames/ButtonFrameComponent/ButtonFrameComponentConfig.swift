// ButtonFrameComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public enum ButtonFrameVariants: String, CaseIterable {
    case disabled
    case generic
    case rainbow
}

public class ButtonFrameComponentConfig: ObservableObject {
    @Published public var frameVariant: ButtonFrameVariants = .generic {
        didSet {
            print("Variant From ButtonFrame is \(frameVariant)")
        }
    }

    @Published public var fillSpace: Bool = true
    @Published public var isCircular: Bool = false
    @Published public var roundness = DesignTokens.defaultCornerRadius
    @Published public var variantGenericBackground = DesignTokens.colors.primary
    @Published public var variantDisabledBackground = DesignTokens.colors.primaryWhitespace3
    @Published public var defaultPadding = DesignTokens.padding.button

    public init(
        frameVariant: ButtonFrameVariants = .generic,
        fillSpace: Bool = true,
        isCircular: Bool = false,
        roundness: CGFloat = DesignTokens.defaultCornerRadius,
        variantGenericBackground: Color = DesignTokens.colors.primary,
        variantDisabledBackground: Color = DesignTokens.colors.primaryWhitespace3,
        defaultPadding: EdgeInsets = DesignTokens.padding.button
    ) {
        print("calling initializer \(frameVariant)")
        self.frameVariant = frameVariant
        self.fillSpace = fillSpace
        self.isCircular = isCircular
        self.roundness = roundness
        self.variantGenericBackground = variantGenericBackground
        self.variantDisabledBackground = variantDisabledBackground
        self.defaultPadding = defaultPadding
    }

    deinit {}
}
