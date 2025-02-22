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

struct ContentView: View {
    var body: some View {
        VStack {
            if KeychainHelper.get(for: .AuthenticationToken) != nil {
                LoginSuccessTemporary()
            } else {
                OnboardingAuthPickerScreen()
            }
        }.task {
            let loop = AuthenticationLoop()
            print("Starting Init first call (we always call here to make sure)")
            await loop.getAccessToken()

            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                print("Looping")
                Task {
                    await loop.getAccessToken()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
