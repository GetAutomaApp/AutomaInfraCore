// ProgressIndicatorComponentConfig.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

enum ProgressIndicatorVariants {
    case generic
}

class ProgressIndicatorComponentConfig: ObservableObject {
    @Published var variant: ProgressIndicatorVariants
    @Published var totalSteps: Int
    var currentStep: Binding<Int>
    @Published var isAnimating: Bool

    @Published var stepLength: CGFloat
    @Published var stepHeight: CGFloat

    init(
        variant: ProgressIndicatorVariants = .generic,
        totalSteps: Int = 4,
        currentStep: Binding<Int>,
        isAnimating: Bool = false,
        stepLength: CGFloat = 7,
        stepHeight: CGFloat = 7
    ) {
        self.variant = variant
        self.totalSteps = totalSteps
        self.currentStep = currentStep
        self.isAnimating = isAnimating
        self.stepLength = stepLength
        self.stepHeight = stepHeight
    }

    var determineStepGrowSize: CGFloat {
        let growSize = CGFloat(
            stepLength + CGFloat(determineSpaceBetweenSteps)
        )

        let currentStepRelative = CGFloat(currentStep.wrappedValue)

        let totalStepsRelative = CGFloat(totalSteps)

        let currentStepFixed = (currentStepRelative >= totalStepsRelative ? totalStepsRelative : currentStepRelative) -
            1

        return growSize * currentStepFixed +
            determineStepLength(0)
    }

    var determineSpaceBetweenSteps: CGFloat {
        stepLength * 1.75
    }

    func determineStepLength(_ step: Int) -> CGFloat {
        step == 0 ? (
            stepLength + determineSpaceBetweenSteps * 2
        ) : stepLength
    }

    func determineStepColour(_ step: Int) -> Color {
        (
            currentStep.wrappedValue - 1 == step && currentStep.wrappedValue - 1 > 0
        ) ? DesignTokens.colors.primary
            .opacity(0.5) : DesignTokens.colors.primary
    }
}
