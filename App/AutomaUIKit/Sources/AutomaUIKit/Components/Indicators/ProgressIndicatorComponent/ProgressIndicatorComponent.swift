// ProgressIndicatorComponent.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

struct ProgressIndicatorComponent: View {
    @ObservedObject var config: ProgressIndicatorComponentConfig

    let onSelfAppear: (ProgressIndicatorComponentConfig) -> Void

    init(
        config: ProgressIndicatorComponentConfig,
        onSelfAppear: @escaping (ProgressIndicatorComponentConfig) -> Void = { _ in }
    ) {
        self.config = config
        self.onSelfAppear = onSelfAppear
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
                    width: config.determineStepGrowSize,
                    height: config.stepHeight
                )
                .foregroundStyle(config.stepColor)
                .animation(config.isAnimating ? .smooth : nil, value: config.currentStep)
        }.onAppear {
            onSelfAppear(config)
        }.animation(config.isAnimating ? .spring : nil, value: config.totalSteps)
    }
}
