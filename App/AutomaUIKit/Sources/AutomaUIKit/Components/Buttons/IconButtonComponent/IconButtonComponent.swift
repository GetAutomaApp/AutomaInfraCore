// IconButtonComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// A custom button component that displays an icon and allows for flexible configuration and action handling.
public struct IconButtonComponent: View {
    /// The external configuration of the button, provided by the parent view.
    @ObservedObject private var externalConfig: IconButtonComponentConfig

    /// A closure that is called when the button appears on screen, passing the current configuration.
    let onSelfAppear: (IconButtonComponentConfig) -> Void

    /// A closure to execute when the button is tapped, passing the current configuration.
    let action: () async throws -> Void

    public var configAction: (IconButtonComponentConfig) -> Void = { _ in }

    // MARK: - 1. Initializer with external config

    /// Initializes the IconButtonComponent with an external configuration.
    ///
    /// - Parameters:
    ///   - config: The external configuration that defines the button's appearance and behavior.
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        config: IconButtonComponentConfig,
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        action: @escaping () async throws -> Void = {}
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
    public init(
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        defaultIcon: DesignIcons = .unknown,
        action: @escaping () async throws -> Void = {}
    ) {
        self.onSelfAppear = onSelfAppear
        self.action = action

        _externalConfig = .init(initialValue: .init())
        externalConfig.icon = defaultIcon
    }

    // MARK: - 2. Initializer with default internal config

    /// Initializes the IconButtonComponent with a default internal configuration.
    ///
    /// - Parameters:
    ///   - onSelfAppear: A closure called when the button appears on screen (default is no-op).
    ///   - defaultIcon: The default icon to display (default is `.unknown`).
    ///   - action: A closure called when the button is tapped (default is no-op).
    public init(
        config: IconButtonComponentConfig = .init(),
        onSelfAppear: @escaping (IconButtonComponentConfig) -> Void = { _ in },
        configAction: @escaping (IconButtonComponentConfig) -> Void = { _ in }
    ) {
        self.onSelfAppear = onSelfAppear
        self.configAction = configAction
        action = {}

        externalConfig = config
    }

    // MARK: - Body

    /// The view body that represents the button. It renders a button frame with the specified icon.
    ///
    /// - Returns: A Button view wrapped in a custom frame, displaying the icon and triggering the associated action.
    public var body: some View {
        ButtonFrameComponent(config: externalConfig, action: {
            configAction(externalConfig)

            Task {
                do {
                    print("starting action")
                    externalConfig.isLoading = true
                    try await action()
                    print("finished action action")
                    externalConfig.isLoading = false
                } catch {
                    externalConfig.isLoading = false
                    throw error
                }
            }
        }) {
            if externalConfig.isLoading {
                // TODO: Convert this to a component so we can have consistent sizing
                ProgressView()
            } else {
                externalConfig.icon.image
                    .foregroundStyle(DesignTokens.colors.textDark)
            }
        } onSelfAppear: { _ in
            onSelfAppear(externalConfig)
        }
    }
}
