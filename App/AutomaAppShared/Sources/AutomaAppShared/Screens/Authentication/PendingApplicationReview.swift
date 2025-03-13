// PendingApplicationReview.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct PendingApplicationReview: View {
    public init() {}

    public var body: some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(
                    config: .init(
                        title: "We'll get back to you soon!",
                        description: """
                        Please message @AdonisCodes on discord in order to continue with the application. \
                        We’d like to hear about your usecase!
                        """
                    )
                )
            },
            footerContent: {
                Spacer()
                ProgressIndicatorComponent(
                    config: .init(totalSteps: 4, currentStep: 4)
                )
                Spacer()
            }
        )
    }
}
