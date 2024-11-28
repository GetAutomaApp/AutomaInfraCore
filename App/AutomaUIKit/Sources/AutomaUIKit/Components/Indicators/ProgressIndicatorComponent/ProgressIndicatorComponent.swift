// ProgressIndicatorComponent.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct ProgressIndicatorComponent: View {
    @ObservedObject var config: ProgressIndicatorComponentConfig

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
                            value: config.currentStep
                        )
                }
            }

            Rectangle()
                .frame(
                    width: config.determineStepGrowSize,
                    height: config.stepHeight
                )
                .foregroundStyle(DesignTokens.colors.primary)
                .animation(.smooth, value: config.currentStep)
        }
    }
}
