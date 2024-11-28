// ProgressIndicatorComponentConfig.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// TODO: Make the correct variables private
import SwiftUI

enum ProgressIndicatorVariants {
    case generic
}

class ProgressIndicatorComponentConfig: ObservableObject {
    @Published var variant: ProgressIndicatorVariants
    @Published var totalSteps: Int
    @Published var currentStep: Int = 1
    @Published var isAnimating: Bool

    @Published var stepLength: CGFloat
    @Published var stepHeight: CGFloat

    init(
        variant: ProgressIndicatorVariants = .generic,
        totalSteps: Int = 4,
        isAnimating: Bool = false,
        stepLength: CGFloat = 7,
        stepHeight: CGFloat = 7
    ) {
        self.variant = variant
        self.totalSteps = totalSteps
        self.isAnimating = isAnimating
        self.stepLength = stepLength
        self.stepHeight = stepHeight
    }

    var determineStepGrowSize: CGFloat {
        let growSize = CGFloat(
            stepLength + CGFloat(determineSpaceBetweenSteps)
        )

        let currentStepRelative = CGFloat(currentStep)

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
            currentStep - 1 == step && currentStep - 1 > 0
        ) ? DesignTokens.colors.primary
            .opacity(0.5) : DesignTokens.colors.primary
    }

    func incrementStep(_ by: Int = 1) {
        let setStepTo = currentStep + by
        guard setStepTo <= totalSteps else { return }
        currentStep = setStepTo
    }

    func decrementStep(_ by: Int = 1) {
        let setStepTo = currentStep - by
        guard setStepTo >= 1 else { return }
        currentStep = setStepTo
    }

    func setStep(_ step: Int) {
        guard currentStep != step, step > 0, step <= totalSteps else { return }

        currentStep = step
    }
}
