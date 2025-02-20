// LoginScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import SwiftUI

public struct LoginScreen: View {
    @StateObject var phoneInputConfig: PhoneNumberTextInputComponentConfig = .init()

    var authInteractor: AuthenticationControllerInteractor = .init(
        baseURL: "https://api-sandbox.getautoma.app"
    )

    public init() {}

    public var body: some View {
        AuthenticationFormScreenFrame(
            isValid: $phoneInputConfig.isValid,
            centerContent: {
                // We need to have the following input stuff
                VStack {
                    PhoneNumberTextInputComponent(config: phoneInputConfig)
                }
            },
            action: {
                await sendAuthenticationCode()
            }
        )
    }

    func sendAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        do {
            let response = try await authInteractor.makeLoginCodeRequest(phoneNumber)
            print("\(response)")
        } catch {
            print("\(error)")
        }
    }
}

#Preview {
    LoginScreen()
        .preferredColorScheme(.dark)
}
