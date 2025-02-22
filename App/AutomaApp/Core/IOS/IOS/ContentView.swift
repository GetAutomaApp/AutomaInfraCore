// ContentView.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaAppShared
import AutomaUIKit
import SwiftUI

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
            loop.startAccessTokenLoop()
        }
    }
}

#Preview {
    ContentView()
}
