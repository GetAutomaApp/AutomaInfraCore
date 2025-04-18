// OnboardingScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

internal struct OnboardingScreenContent {
    public let title: String
    public let description: String
    public let background: Color = DesignTokens.colors.primary
}

public struct OnboardingScreen: View {
    @ObservedObject public var titleConfig: InfoPairComponentConfig = .init()
    @ObservedObject public var progressIndicatorConfig: ProgressIndicatorComponentConfig = .init()
    @ObservedObject public var iconButtonConfig: IconButtonComponentConfig = .init()
    @State public var shouldShowApplyScreen: Bool = false
    @State private var shouldShowRegisterScreen: Bool = false

    let onboardingScreenContent: [OnboardingScreenContent] = [
        .init(
            title: "Create & manage profiles",
            description: "Automa provides a platform to create and manage social media accounts seamlessly with our integrated tools."
        ),
        .init(
            title: "Earn & manage profits",
            description: "Automa has a robust set of tools that can be leveraged to help you earn an income from your newly found fame."
        ),
        .init(
            title: "AI that generates content",
            description: "Automa automatically creates high quality content via our robust AI technology, that automates everything."
        ),
        .init(
            title: "Exclusive Community",
            description: "Automa is built on community, trust and friendship. With recurring events, success stories and more!"
        ),
    ]

    public init() {}

    public var body: some View {
        if shouldShowRegisterScreen {
            RegisterScreen()
        } else if shouldShowApplyScreen {
            generateApplyView()
        } else {
            generateOnboardingView()
        }
    }

    @ViewBuilder
    private func generateOnboardingView() -> some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(config: titleConfig) { config in
                    config.title = onboardingScreenContent[0].title
                    config.description = onboardingScreenContent[0].description
                }
                .animation(
                    .bouncy,
                    value: progressIndicatorConfig.currentStep
                )
            },
            footerContent: {
                ProgressIndicatorComponent(config: progressIndicatorConfig) { config in
                    config.totalSteps = onboardingScreenContent.count
                }
                Spacer()
                IconButtonComponent(
                    config: iconButtonConfig,
                    onSelfAppear: { _ in
                        iconButtonConfig.variant = .circle
                        iconButtonConfig.icon = .arrowRight
                    }
                ) {
                    handleOnboardingNextScreen()
                }
            }
        )
    }

    @ViewBuilder
    private func generateApplyView() -> some View {
        OnboardingScreenFrame(
            titleContent: {
                InfoPairComponent(config: titleConfig) { config in
                    config.title = "Apply to Join"
                    config
                        .description =
                        "We are a closed community, accepting the highest quality candidates only. If you are ambitious, click next!"
                }
            },
            footerContent: {
                IconButtonComponent(
                    defaultIcon: .arrowRight
                ) {
                    shouldShowApplyScreen = false
                    shouldShowRegisterScreen = true
                }
            }
        ).animation(.bouncy, value: progressIndicatorConfig.currentStep)
    }

    public func handleOnboardingNextScreen() {
        if progressIndicatorConfig.currentStep == onboardingScreenContent.count {
            shouldShowApplyScreen = true
            return
        }

        progressIndicatorConfig.currentStep += 1
        titleConfig.title = onboardingScreenContent[progressIndicatorConfig.currentStep - 1].title
        titleConfig.description = onboardingScreenContent[progressIndicatorConfig.currentStep - 1].description
    }
}

#Preview {
    OnboardingScreen()
        .preferredColorScheme(.dark)
}
