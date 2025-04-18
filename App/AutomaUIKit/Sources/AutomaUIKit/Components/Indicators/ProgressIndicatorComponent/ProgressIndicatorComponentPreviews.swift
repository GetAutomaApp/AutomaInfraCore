// ProgressIndicatorComponentPreviews.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

internal struct ProgressIndicatorComponentPreviews: PreviewProvider {
    static var previews: some View {
        TestProgressView()
    }
}

internal struct TestProgressView: View {
    @ObservedObject public var config = ProgressIndicatorComponentConfig()

    public var body: some View {
        VStack {
            PropertyEditor(object: config, properties: [
                [AnyKeyPath("Total Steps", keyPath: \.totalSteps)],
                [AnyKeyPath("Current Step", keyPath: \.currentStep)],
                [AnyKeyPath("Enable Animation", keyPath: \.isAnimating)],
                [AnyKeyPath("Step Length", keyPath: \.stepLength)],
                [AnyKeyPath("Step Height", keyPath: \.stepHeight)],
                [AnyKeyPath("Step Colour", keyPath: \.stepColour)],
            ]) {
                VStack {
                    HStack {
                        Spacer()
                        ProgressIndicatorComponent(config: config) { config in
                            config.currentStep = 1
                        }
                        Spacer()
                    }.padding(.bottom)

                    Button("Reset Current Step") {
                        config.setStep(1)
                    }
                }
            }
        }
    }
}
