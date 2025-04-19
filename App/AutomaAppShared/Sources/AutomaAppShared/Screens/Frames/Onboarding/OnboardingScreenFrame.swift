// OnboardingScreenFrame.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

/// A view that provides a standardized layout frame for onboarding screens.
/// This component splits the screen into two main sections:
/// - A top section with a primary background color (60% of screen height)
/// - A bottom section with a black background (40% of screen height)
///
/// The layout adapts based on the platform, using a vertical stack on iOS and horizontal stack on other platforms.
///
/// Usage:
/// ```
/// OnboardingScreenFrame {
///     Text("Welcome")  // Title content
/// } footerContent: {
///     Button("Get Started") { }  // Footer content
/// }
/// ```
public struct OnboardingScreenFrame<TitleContent: View, FooterContent: View>: View {
    /// Closure that provides the title content to be displayed in the frame.
    /// This content will be positioned at the top of the bottom section.
    public let titleContent: () -> TitleContent

    /// Closure that provides the footer content to be displayed in the frame.
    /// This content will be positioned at the bottom of the bottom section.
    public let footerContent: () -> FooterContent

    /// Initializes a new onboarding screen frame with customizable title and footer content.
    /// - Parameters:
    ///   - titleContent: A closure returning the view to be displayed as the title content.
    ///     This view will be aligned to the leading edge of the screen.
    ///   - footerContent: A closure returning the view to be displayed as the footer content.
    ///     This view will be positioned at the bottom of the screen.
    public init(
        @ViewBuilder titleContent: @escaping () -> TitleContent,
        @ViewBuilder footerContent: @escaping () -> FooterContent
    ) {
        self.titleContent = titleContent
        self.footerContent = footerContent
    }

    /// The body of the view that defines the onboarding screen layout.
    /// This view creates a split-screen layout with:
    /// - A top section taking 60% of the screen height with primary background color
    /// - A bottom section taking 40% of the screen height with black background
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

    /// Determines the appropriate stack type based on the current platform.
    /// This method ensures the layout adapts correctly across different devices.
    /// - Returns: The stack variant to use for layout:
    ///   - `.vstack` for iOS devices (vertical layout)
    ///   - `.hstack` for other platforms (horizontal layout)
    public func determineStackType() -> AnyOrientationStackComponentVariants {
        #if os(iOS)
            return .vstack
        #else
            return .hstack
        #endif
    }
}

/// Provides a preview of the OnboardingScreenFrame in SwiftUI's preview canvas
#Preview {
    OnboardingScreen()
}
