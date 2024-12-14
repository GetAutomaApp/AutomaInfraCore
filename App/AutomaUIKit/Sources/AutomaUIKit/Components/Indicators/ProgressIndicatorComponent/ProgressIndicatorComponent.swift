// ProgressIndicatorComponent.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/**
 The `ProgressIndicatorComponenent` is a reusable component that allows you to present some kind of progression of tasks to the user.

 This component has the ability to easily be wrapped & converted into any other component  that is needed (that has similar logic), here are some cases:
 - Loading bar can use this by growing the height of each step & slowly stepping over each step.
 - Progress bar to represent the progress of some background work by stepping through a set amount of steps

 For more information, refer to the documentation in `ProgressIndicatorComponentDocumentation.md`
 */
public struct ProgressIndicatorComponent: View {
    // The Config used to manipulate this component's state.
    @ObservedObject var config: ProgressIndicatorComponentConfig

    // Allows you to customise the configuration once this apears, this could also be used as a reset state in more
    // complex cases like scroll views.
    let onSelfAppear: (ProgressIndicatorComponentConfig) -> Void

    public init(
        config: ProgressIndicatorComponentConfig,
        onSelfAppear: @escaping (ProgressIndicatorComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onSelfAppear = onSelfAppear
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(0 ..< config.totalSteps, id: \.self) { step in

                    Rectangle()
                        .frame(
                            width: config.determineStepLength(step),
                            height: config.stepHeight
                        )
                        .foregroundStyle(
                            config.determineStepColour(step)
                        )
                        .padding(.trailing,
                                 step == config.totalSteps - 1 ? 0 : config.determineSpaceBetweenSteps)
                        .animation(
                            config.isAnimating ? .spring : nil,
                            value: config.currentStep
                        )
                }
            }

            Rectangle()
                .frame(
                    width: config.determineStepLengthGrowSize,
                    height: config.stepHeight
                )
                .foregroundStyle(config.stepColour)
                .animation(config.isAnimating ? .smooth : nil, value: config.currentStep)
                .tag("progress-indicator-overlay")
        }.onAppear {
            onSelfAppear(config)
        }.animation(config.isAnimating ? .spring : nil, value: config.totalSteps)
    }
}
