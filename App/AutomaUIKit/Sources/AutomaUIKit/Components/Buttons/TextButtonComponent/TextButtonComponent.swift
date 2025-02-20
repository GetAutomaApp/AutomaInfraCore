// TextButtonComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// A custom button component that displays an icon and allows for flexible configuration and action handling.
public struct TextButtonComponent: View {
    /// The external configuration of the button, provided by the parent view.
    @ObservedObject private var externalConfig: TextButtonComponentConfig

    /// The configuration to use for the button. This is either the external or internal config.
    private var config: TextButtonComponentConfig { externalConfig }

    /// A closure that is called when the button appears on screen, passing the current configuration.
    let onSelfAppear: (TextButtonComponentConfig) -> Void

    /// A closure to execute when the button is tapped, passing the current configuration.
    let action: (TextButtonComponentConfig) -> Void

    // MARK: - 1. Initializer with external config

    /// Initializes the TextButtonComponent with an external configuration.
    ///
    /// - Parameters:
    ///   - config: The external configuration that defines the button's appearance and behavior.
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        config: TextButtonComponentConfig,
        onSelfAppear: @escaping (TextButtonComponentConfig) -> Void = { _ in },
        action: @escaping (TextButtonComponentConfig) -> Void = { _ in }
    ) {
        externalConfig = config
        self.onSelfAppear = onSelfAppear
        self.action = action
    }

    // MARK: - 2. Initializer with default internal config

    /// Initializes the TextButtonComponent with a default internal configuration.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultText: The default text the button should display
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        onSelfAppear: @escaping (TextButtonComponentConfig) -> Void = { _ in },
        defaultText: String,
        action: @escaping (TextButtonComponentConfig) -> Void
    ) {
        self.onSelfAppear = onSelfAppear
        self.action = action

        _externalConfig = .init(initialValue: .init())
        externalConfig.text = defaultText
    }

    // MARK: - 3. Initializer with action without config

    /// Initializes the TextButtonComponent with a closure for action, but no external configuration.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultText: The default text the button should display
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        onSelfAppear: @escaping (TextButtonComponentConfig) -> Void = { _ in },
        defaultText: String,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            onSelfAppear: onSelfAppear,
            defaultText: defaultText,
            action: { _ in action() }
        )
    }

    // MARK: - Body

    /// The view body that represents the button. It renders a button frame with the specified text
    ///
    /// - Returns: A Button view wrapped in a custom frame, displaying the text and triggering the associated action.
    public var body: some View {
        ButtonFrameComponent(config: config, action: {
            action(config)
        }) {
            Text(config.text)
                .fontTableFont(
                    FontTable.SFPro.Body.body1,
                    DesignTokens.colors
                        .textDark
                )
        } onSelfAppear: { _ in
            print("calling on self appear button frame comp")
            onSelfAppear(config)
        }
    }
}
