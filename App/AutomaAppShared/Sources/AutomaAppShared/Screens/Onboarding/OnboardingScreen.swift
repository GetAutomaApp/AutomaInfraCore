// OnboardingScreen.swift
// Copyright (c) 2024 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  OnboardingScreen.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 12/5/24.
//
import AutomaUIKit
import SwiftUI

struct OnboardingScreenContent {
    let title: String
    let description: String
    let background: Color = DesignTokens.colors.primary
}

// TODO: Figure this out
// TODO: Extend `.frame` to allow for (variant: .screen, height: 0.7)
public struct OnboardingScreen: View {
    @ObservedObject var titleConfig: InfoPairComponentConfig = .init()
    @ObservedObject var progressIndicatorConfig: ProgressIndicatorComponentConfig = .init()
    @ObservedObject var iconButtonConfig: IconButtonComponentConfig = .init()
    @State var shouldShowApplyScreen: Bool = false

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

    public var body: some View {
        VStack(spacing: 0) {
            VStack {
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .frame(maxWidth: .infinity)
            .background(.green)

            VStack(alignment: .leading) {
                HStack {
                    InfoPairComponent(config: titleConfig) { config in
                        config.title = "Create & manage profiles"
                        config
                            .description =
                            "Automa provides a platform to create and manage social media accounts seamlessly with our integrated tools."
                    }
                    Spacer()
                }
                Spacer()

                HStack(alignment: .bottom) {
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
                    ) { _ in
                        handleOnboardingNextScreen()
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 40)
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .frame(maxWidth: .infinity)
            .background(.black)
        }
        .ignoresSafeArea()
    }

    func handleOnboardingNextScreen() {
        if progressIndicatorConfig.currentStep == onboardingScreenContent.count {
            shouldShowApplyScreen = true
            return
        }

        progressIndicatorConfig.currentStep += 1
        let currentScreen = onboardingScreenContent[progressIndicatorConfig.currentStep - 1]

        titleConfig.title = currentScreen.title
        titleConfig.description = currentScreen.description
    }
}

#Preview {
    OnboardingScreen()
}
