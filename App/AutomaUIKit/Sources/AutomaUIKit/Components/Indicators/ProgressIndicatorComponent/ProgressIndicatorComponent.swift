// ProgressIndicatorComponent.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

// NOTE: The progress indicator will determine show the progress as follows (with an example):
// (x represents where the overlay currently is)
//  Hence the current step should always start at 1
// Total steps 5 - - - - -
// Current step 0 - - - - -
// Current step 1 x - - - -
// Current step 2 xxx - - -
// Current step 3 xxxxx - -
// Current step 4 xxxxxxx -
// Current step 5 xxxxxxxxx

struct ProgressIndicatorComponent: View {
    @ObservedObject var config: ProgressIndicatorComponentConfig

    init(
        config: ProgressIndicatorComponentConfig? = nil,
        totalSteps: Int? = nil,
        currentStep: Binding<Int>
    ) {
        if let config {
            config.currentStep = currentStep
            self.config = config
        } else {
            self.config = .init(currentStep: currentStep)
        }

        guard let totalSteps else { return }

        self.config.totalSteps = totalSteps
    }

    var body: some View {
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
                        .padding(.trailing, config.determineSpaceBetweenSteps)
                        .animation(
                            .spring,
                            value: config.currentStep.wrappedValue
                        )
                }
            }

            Rectangle()
                .frame(
                    width: config.determineStepGrowSize,
                    height: config.stepHeight
                )
                .foregroundStyle(DesignTokens.colors.primary)
                .animation(.smooth, value: config.currentStep.wrappedValue)
        }
    }
}
