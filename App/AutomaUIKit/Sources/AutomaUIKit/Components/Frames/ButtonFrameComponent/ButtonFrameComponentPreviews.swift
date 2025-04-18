// ButtonFrameComponentPreviews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct ButtonFrameComponentPreviews: PreviewProvider {
    static var previews: some View {
        ButtonFrameComponentPreviewsView()
    }
}

internal struct ButtonFrameComponentPreviewsView: View {
    @StateObject public var buttonConfig: ButtonFrameComponentConfig = .init()

    public var body: some View {
        PropertyEditor(
            object: buttonConfig,
            properties: [
                [AnyKeyPath("Fill Space", keyPath: \.fillSpace)],
                [AnyKeyPath("Is Circular", keyPath: \.isCircular)],
                [AnyKeyPath("Padding", keyPath: \.defaultPadding)],
                [AnyKeyPath("Roundness", keyPath: \.roundness)],
                [AnyKeyPath("Generic Background", keyPath: \.variantGenericBackground)],
                [AnyKeyPath("Disabled Background", keyPath: \.variantDisabledBackground)],
            ]
        ) {
            VStack {
                AutoButtonVariationsView()
                HStack {
                    ButtonFrameComponent(config: buttonConfig, action: {
                        print("Clicked Me")
                    }) {
                        Text("Hello, World")
                            .fontTableFont(FontTable.SFPro.Body.body4)
                    }

                    ButtonFrameComponent(config: buttonConfig, action: {
                        print("Clicked Me")
                    }) {
                        Image(systemName: "play.fill")
                    }
                }

                EnumPropertyView(
                    value: $buttonConfig.frameVariant,
                    cases: ButtonFrameVariants.allCases
                )
            }
        }
    }
}

internal struct AutoButtonVariationsView: View {
    @StateObject public var buttonController: ButtonFrameComponentConfig = .init()
    @State private var isTimerActive = false

    public let switchDelay: TimeInterval = 0.5

    public var body: some View {
        HStack {
            ButtonFrameComponent(config: buttonController, action: { config in
                config.isCircular.toggle()
                config.frameVariant = .disabled
            }) { _ in
                ProgressView()
            } onSelfAppear: { _ in
                startChangingVariant()
            }

            Spacer()

            IconButtonComponent(onSelfAppear: { config in config.variant = .square }, configAction: { config in
                isTimerActive ? stopChangingVariant() : startChangingVariant()
                config.icon = isTimerActive ? .pause : .play
            })
        }
    }

    public func startChangingVariant() {
        if isTimerActive {
            return
        }

        isTimerActive = true

        DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
            updateVariant()
        }
    }

    public func updateVariant() {
        buttonController.frameVariant = .allCases.randomElement()!
        buttonController.isCircular = .random()
        buttonController.fillSpace = .random()

        if isTimerActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + switchDelay) {
                updateVariant()
            }
        }
    }

    public func stopChangingVariant() {
        isTimerActive = false
    }
}
