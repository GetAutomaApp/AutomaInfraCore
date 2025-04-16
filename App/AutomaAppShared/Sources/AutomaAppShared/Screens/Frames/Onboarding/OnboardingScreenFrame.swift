// OnboardingScreenFrame.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct OnboardingScreenFrame<TitleContent: View, FooterContent: View>: View {
    let titleContent: () -> TitleContent
    let footerContent: () -> FooterContent

    public init(
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.titleContent = titleContent
        self.footerContent = footerContent
    }

    public var body: some View {
        AnyOrientationStackComponent(
            config: .init(variant: determineStackType())
        ) {
            VStack {
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height * 0.6)
            .frame(maxWidth: .infinity)
            .background(DesignTokens.colors.primary)

            VStack(alignment: .leading) {
                HStack {
                    titleContent()
                    Spacer()
                }
                Spacer()

                HStack(alignment: .bottom) {
                    footerContent()
                }
            }
            .defaultScreenPadding()
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .frame(maxWidth: .infinity)
            .background(.black)
        }
        .ignoresSafeArea()
    }

    public func determineStackType() -> AnyOrientationStackComponentVariants {
        #if os(iOS)
            return .vstack
        #else
            return .hstack
        #endif
    }
}

#Preview {
    OnboardingScreen()
}
