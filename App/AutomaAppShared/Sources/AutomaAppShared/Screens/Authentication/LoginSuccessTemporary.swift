// LoginSuccessTemporary.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

// RegisterScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct LoginSuccessTemporary: View {
    public init() {}

    public var body: some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(
                    config: .init(
                        title: "We'll get back to you soon!",
                        description: "We are taking a thorough look at your application. We will notify you via sms & notifications on further updates!"
                    )
                )
            },
            footerContent: {
                HStack {
                    Spacer()
                    ProgressIndicatorComponent(
                        config: .init(totalSteps: 4, currentStep: 4)
                    )
                    Spacer()
                }
            }
        )
    }
}
