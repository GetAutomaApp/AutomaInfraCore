// ProgressIndicatorComponentConfig.swift
// was created on 11/28/24
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

/// This enum contains all of the different variants that the `ProgressIndicatorComponent` can use to represent it self
enum ProgressIndicatorVariants {
    case generic
}

/// Configuration class for customizing the appearance and behaviour of the `ProgressIndicatorComponent`
class ProgressIndicatorComponentConfig: ObservableObject {
    /// Determines the variation of the ProgressIndicator component (more to come in the future)
    @Published var variant: ProgressIndicatorVariants
    /// The total steps that the component should generate. Defaults to 4
    @Published var totalSteps: Int
    /// The current step the stepper should be at (represented & managed by the variant)
    @Published var currentStep: Int = 1
    /// If the component should have any animation at all (this is for testing purposes, or to extend this component and
    /// add custom animations)
    @Published var isAnimating: Bool

    /// The length the steps should be (the variant can change the length of a step based on current step & other
    /// factors)
    @Published var stepLength: CGFloat
    /// The height the steps should be (the variant can change the height of a step based on current step & other
    /// factors)
    @Published var stepHeight: CGFloat
    /// The `primary` colour used by the ProgressIndicator (the variant can change the colour based on the current step
    /// and other factors)
    @Published var stepColour: Color

    /// Default initializer
    init(
        variant: ProgressIndicatorVariants = .generic,
        totalSteps: Int = 4,
        isAnimating: Bool = true,
        stepLength: CGFloat = 7,
        stepHeight: CGFloat = 7,
        stepColor: Color = DesignTokens.colors.primary
    ) {
        self.variant = variant
        self.totalSteps = totalSteps
        self.isAnimating = isAnimating
        self.stepLength = stepLength
        self.stepHeight = stepHeight
        stepColour = stepColor
    }

    /// Determines the step overlay length for the `generic` variant
    var determineStepLengthGrowSize: CGFloat {
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

    /// Determines the padding between steps for the `generic` variant
    var determineSpaceBetweenSteps: CGFloat {
        stepLength * 1.75
    }

    /// Determines the step length for the `generic` variant
    func determineStepLength(_ step: Int) -> CGFloat {
        step == 0 ? (
            stepLength + determineSpaceBetweenSteps * 2
        ) : stepLength
    }

    /// Determines the step colour for the `generic` variant
    func determineStepColour(_ step: Int) -> Color {
        (
            currentStep - 1 == step && currentStep - 1 > 0
        ) ? stepColour.opacity(0.5) : stepColour
    }

    // MARK: - TODO: Make these methods use min/max combinations to determine what to assign the steps

    // The code will be way cleaner

    /// A method to increment the step count by one or `byCount`
    /// This method ensures to clamp the value to the max if you provide an overflow
    func incrementStep(_ byCount: Int = 1) {
        let setStepTo = currentStep + byCount
        guard setStepTo <= totalSteps else {
            /// Set the step count to the max amount of steps if the user overflows the clamp
            currentStep = totalSteps
            return
        }
        currentStep = setStepTo
    }

    func decrementStep(_ byCount: Int = 1) {
        let setStepTo = currentStep - byCount
        guard setStepTo >= 1 else {
            /// Set the step count to 1 if the user overflows the min clamp
            currentStep = 1
            return
        }
        currentStep = setStepTo
    }

    /// Sets the step to a specific one (with a min/max clamp)
    func setStep(_ step: Int) {
        guard currentStep != step, step > 0, step <= totalSteps else { return }

        currentStep = step
    }
}
