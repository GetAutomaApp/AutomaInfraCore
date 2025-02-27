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
                        description: "We are taking a thorough look at your application. We will notify you via sms & notifications on further updates!"
                    )
                )
            },
            footerContent: {
                Text(
                    "Please Message @AdonisCodes on discord. We'd like to discuss your usecase for this app in order to aid us in approving your application!"
                )
                .fontTableFont(
                    FontTable.SFPro.Body.body3,
                    DesignTokens.colors.primaryText
                )
            }
        )
    }
}
