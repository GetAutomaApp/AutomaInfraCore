// ButtonFrameComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 A reusable button component that allows for flexible configuration of its action, content, and appearance.

 This component supports multiple initializer variations to allow for different configurations of actions and content:
 - Action with or without configuration
 - Content with or without configuration
 - Automatic configuration defaults if no custom values are provided.

 For more information, refer to the documentation in `ButtonFrameComponentDocumentation.md`.
 */
internal struct ButtonFrameComponent<Content: View>: View {
    // Default configuration state for the button. Used when no custom configuration is provided.
    @ObservedObject private var config: ButtonFrameComponentConfig

    // Closure that defines the button's action when tapped, using the current configuration.
    let action: (ButtonFrameComponentConfig) -> Void

    // Closure called when the component appears on the screen, allowing for configuration adjustments.
    let onSelfAppear: (ButtonFrameComponentConfig) -> Void

    // Closure that provides the content of the button, using the current configuration.
    var content: (ButtonFrameComponentConfig) -> Content

    // MARK: - Initializer 1: Action with config, content without config

    /**
     Initializes a `ButtonFrameComponent` where the action uses the button's configuration and the content is static.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    init(config: ButtonFrameComponentConfig,
         action: @escaping (ButtonFrameComponentConfig) -> Void,
         @ViewBuilder content: @escaping () -> Content,
         onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
    {
        self.config = config

        self.action = action
        self.onSelfAppear = onSelfAppear
        self.content = { _ in content() }
    }

    // MARK: - Initializer 2: Content with config, action without config

    /**
     Initializes a `ButtonFrameComponent` where the content uses the button's configuration and the action is static.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A ViewBuilder closure that exposes the config, Returns `some View`
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    init(config: ButtonFrameComponentConfig,
         action: @escaping () -> Void,
         @ViewBuilder content: @escaping (ButtonFrameComponentConfig) -> Content,
         onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
    {
        self.config = config

        self.action = { _ in action() }
        self.onSelfAppear = onSelfAppear
        self.content = content
    }

    // MARK: - Initializer 3: Neither action nor content use config

    /**
     Initializes a `ButtonFrameComponent` where neither the action nor the content uses the configuration.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action triggered when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    init(config: ButtonFrameComponentConfig,
         action: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content,
         onSelfAppear: @escaping (ButtonFrameComponentConfig) -> Void = { _ in })
    {
        self.config = config

        self.action = { _ in action() }
        self.onSelfAppear = onSelfAppear
        self.content = { _ in content() }
    }

    // MARK: - Initializer 4: Both action and content use config

    /**
     Initializes a `ButtonFrameComponent` where both the action and content use the configuration.

     - Parameter config: An optional configuration object to customize the button's appearance.
     - Parameter action: A closure that defines the action when the button is tapped.
     - Parameter content: A closure returning the content view to be displayed inside the button.
     - Parameter onSelfAppear: A closure called when the button appears on screen.
     */
    init(
        config: ButtonFrameComponentConfig,
        action: @escaping (
            ButtonFrameComponentConfig
        ) -> Void,
        @ViewBuilder content: @escaping (
            ButtonFrameComponentConfig
        ) -> Content,
        onSelfAppear: @escaping (
            ButtonFrameComponentConfig
        ) -> Void = {
            _ in
        }
    ) {
        self.config = config

        self.action = action
        self.onSelfAppear = onSelfAppear
        self.content = content
    }

    // MARK: - Body

    /**
     The body of the button, which defines the layout and interaction behavior.

     - The button's action triggers the `action` closure with the current configuration.
     - The content view is rendered based on the configuration.
     - The button's appearance (padding, background, corner radius, etc.) is adjusted based on the configuration.
     */
    var body: some View {
        Button(action: {
            action(config)
        }) {
            content(config)
                .frame(maxWidth: config.fillSpace ? .infinity : nil)
                .padding(config.defaultPadding)
                .background(determineBackgroundColor()) // Apply background color based on variant
        }
        .cornerRadius(config.isCircular ? .infinity : config.roundness)
        .disabled(config.frameVariant == .disabled) // Disable button via SwiftUI properties if variant is disabled
        .frame(minWidth: 0, minHeight: 0)
        .onAppear {
            print("calling from bframe")
            onSelfAppear(config) // Trigger onAppear closure when button appears
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper Function: Determine Background Color

    /**
     Determines and returns the appropriate background color for the button based on the configuration's variant.

     - Returns: A view representing the button's background (gradient or solid color).
     */
    func determineBackgroundColor() -> some View {
        Group {
            switch config.frameVariant {
            case .disabled:
                config.variantDisabledBackground // Background for disabled state
            case .generic:
                config.variantGenericBackground // Generic background for normal state
            case .rainbow:
                // Gradient background with a rainbow color scheme
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}
