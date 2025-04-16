// ContentView.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import AutomaUIKit
import SwiftUI

// Tasks:
// 1. Convert Authentication Token & Access Token to binding
// 2. Make sure we use this binding everywhere
// 3. Add `automaAuthCode` to backend-interactor which is true/false (uses the env object)
// 4. Make sure functionality works if refresh token gets set to null we go back to the onboarding screen

internal struct ContentView: View {
    @EnvironmentObject var baseEnvironmentConfig: BaseAppEnvironmentObject
    @EnvironmentObject var networkChecker: NetworkManager

    public var body: some View {
        if networkChecker.isConnected {
            VStack {
                if baseEnvironmentConfig.isAppFinishedLoading {
                    if baseEnvironmentConfig.shouldUpdateApp {
                        ForceUpdate()
                    } else if baseEnvironmentConfig.isLoggedIn, baseEnvironmentConfig.isAccepted {
                        LoginSuccessTemporary()
                    } else if baseEnvironmentConfig.isLoggedIn {
                        PendingApplicationReview()
                    } else {
                        OnboardingAuthPickerScreen()
                    }
                } else {
                    ProgressView()
                }
            }
        } else {
            NoNetworkConnectionView()
        }
    }
}

#Preview {
    ContentView()
}
