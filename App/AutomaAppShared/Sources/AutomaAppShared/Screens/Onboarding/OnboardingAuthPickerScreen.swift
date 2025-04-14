// OnboardingAuthPickerScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

enum AuthScreenRoute {
    case register
    case login
}

public struct OnboardingAuthPickerScreen: View {
    @State private var path: [AuthScreenRoute] = []

    public init() {}

    public var body: some View {
        NavigationStack(path: $path) {
            OnboardingScreenFrame(
                titleContent: makeTitleContent,
                footerContent: makeFooter
            )
            .navigationDestination(for: AuthScreenRoute.self) { screen in
                switch screen {
                case .register:
                    OnboardingScreen()
                        .navigationBarBackButtonHidden(true)
                case .login:
                    LoginScreen()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }

    @ViewBuilder
    private func makeTitleContent() -> some View {
        InfoPairComponent(config:
            .init(
                title: "Welcome to Automa!",
                description: "The most advanced content automation solution known to humanity!"
            ))
    }

    @ViewBuilder
    private func makeFooter() -> some View {
        VStack {
            TextButtonComponent(defaultText: "Register") {
                path = [
                    .register,
                ]
            }
            TextButtonComponent(defaultText: "Login") {
                path = [
                    .login,
                ]
            }
        }
    }
}

#Preview {
    OnboardingAuthPickerScreen()
}
