// TextButtonComponentConfig.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// Enum defining the different variants of the TextButton component.
public enum TextButtonVariants: String, CaseIterable {
    case circle
    case generic
    case pill
    case square
}

/// Configuration for the TextButtonComponent that extends from `ButtonFrameComponentConfig`.
/// It defines the visual style, state (enabled/disabled), and the default text.
public class TextButtonComponentConfig: ButtonFrameComponentConfig {
    /// The variant of the button (e.g., generic, square, circle, pill).
    /// This controls the button's shape and layout style.
    @Published public var variant: TextButtonVariants = .generic {
        didSet {
            applyVariantStyling()
        }
    }

    /// Whether the button is disabled or not. When disabled, the button appears inactive.
    @Published var isDisabled: Bool = false {
        didSet {
            manageDisabledState()
        }
    }

    /// The text to display on the button. This defines the visual text that the button will use
    @Published public var text: String = "Enter Text Here"

    /// Initializes the `TextButtonComponentConfig` with default styling.
    ///
    /// This calls the superclass's initializer and applies the default styling for the button's variant.
    public init() {
        super.init()
        applyVariantStyling()
    }

    /// Applies the appropriate styling based on the selected variant.
    ///
    /// This method adjusts properties like `isCircular`, `roundness`, `fillSpace`, and `defaultPadding`
    /// based on the button's variant (generic, square, circle, or pill).
    public func applyVariantStyling() {
        switch variant {
        case .generic:
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = true
        case .square:
            isCircular = false
            roundness = DesignTokens.defaultCornerRadius
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .circle:
            isCircular = true
            fillSpace = false
            defaultPadding = DesignTokens.padding.buttonEven
        case .pill:
            isCircular = true
            fillSpace = true
            defaultPadding = DesignTokens.padding.button
        }
    }

    /// Manages the disabled state of the button.
    ///
    /// When the button is disabled (`isDisabled = true`), the button's frame variant is set to `.disabled`.
    /// If the button is not disabled, it uses the `.generic` frame variant.
    public func manageDisabledState() {
        frameVariant = isDisabled ? .disabled : .generic
    }
}
