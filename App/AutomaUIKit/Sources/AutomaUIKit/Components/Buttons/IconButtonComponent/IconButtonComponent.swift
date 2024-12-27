// IconButtonComponent.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// A custom button component that displays an icon and allows for flexible configuration and action handling.
struct IconButtonComponent: View {
    /// The internal configuration of the button, managed within the component.
    @StateObject private var internalConfig: IconButtonComponentConfig = .init()

    /// The external configuration of the button, provided by the parent view.
    @ObservedObject private var externalConfig: IconButtonComponentConfig

    /// The configuration to use for the button. This is either the external or internal config.
    private var config: IconButtonComponentConfig { externalConfig }

    /// A closure that is called when the button appears on screen, passing the current configuration.
    let onSelfAppear: (IconButtonComponentConfig) -> Void

    /// A closure to execute when the button is tapped, passing the current configuration.
    let action: (IconButtonComponentConfig) -> Void

    // MARK: - 1. Initializer with external config

    /// Initializes the IconButtonComponent with an external configuration.
    ///
    /// - Parameters:
    ///   - config: The external configuration that defines the button's appearance and behavior.
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - action: A closure called when the button is tapped (default is no-op).
    init(
        config: IconButtonComponentConfig,
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        action: @escaping (IconButtonComponentConfig) -> Void = { _ in }
    ) {
        externalConfig = config
        self.onSelfAppear = onSelfAppear
        self.action = action
    }

    // MARK: - 2. Initializer with default internal config

    /// Initializes the IconButtonComponent with a default internal configuration.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultIcon: The default icon to display (default is `.unknown`).
    ///   - action: A closure called when the button is tapped (default is no-op).
    init(
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        defaultIcon: DesignIconsEnum = .unknown,
        action: @escaping (IconButtonComponentConfig) -> Void = { _ in }
    ) {
        self.onSelfAppear = onSelfAppear
        self.action = action

        _internalConfig = StateObject(wrappedValue: {
            let config = IconButtonComponentConfig()
            config.icon = defaultIcon
            return config
        }())
        externalConfig = _internalConfig.wrappedValue
    }

    // MARK: - 3. Initializer with action without config

    /// Initializes the IconButtonComponent with a closure for action, but no external configuration.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultIcon: The default icon to display (default is `.unknown`).
    ///   - action: A closure called when the button is tapped (default is no-op).
    init(
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        defaultIcon: DesignIconsEnum = .unknown,
        action: @escaping () -> Void = {}
    ) {
        self.init(
            onSelfAppear: onSelfAppear,
            defaultIcon: defaultIcon,
            action: { _ in action() }
        )
    }

    // MARK: - Body

    /// The view body that represents the button. It renders a button frame with the specified icon.
    ///
    /// - Returns: A Button view wrapped in a custom frame, displaying the icon and triggering the associated action.
    var body: some View {
        ButtonFrameComponent(config: config, action: {
            action(config)
        }) {
            config.icon.image
        } onSelfAppear: { _ in
            onSelfAppear(config)
        }
    }
}
