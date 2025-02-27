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
                        title: "Thanks for your patience!",
                        description: "The app is currently being developed. This screen will be removed once the app is open for general use!"
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
