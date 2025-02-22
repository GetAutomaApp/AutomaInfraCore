// LoginScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import DataTypes
import SwiftUI

public struct LoginScreen: View {
    @StateObject var phoneInputConfig: PhoneNumberTextInputComponentConfig = .init()
    @StateObject var verificationInputConfig: VerificationCodeInputComponentConfig = .init()
    @State var timeout: Double = 0

    var authInteractor: AuthenticationControllerInteractor = .init(
        baseURL: "https://api-sandbox.getautoma.app"
    )

    @State private var wasPreviousErrorTimeout: Bool = false
    @State private var timer: Timer? // To avoid race conditions
    @State private var didSendCode: Bool = false
    @State private var isValidVerificationScreenState: Bool = false

    private var formattedTimeout: String {
        let error = String(format: "%.2f", timeout)
        if !didSendCode {
            return "Please wait \(error)s before trying again!"
        } else {
            return "Please wait \(error)s before resending the code!"
        }
    }

    public init() {}

    public var body: some View {
        VStack {
            if !didSendCode {
                AuthenticationFormScreenFrame(
                    title: "Verify your phone number",
                    description: "What is your phone number?",
                    isValid: createIsValidPhoneNumberBinding(),
                    centerContent: {
                        VStack {
                            PhoneNumberTextInputComponent(config: phoneInputConfig)
                        }
                    },
                    action: {
                        await sendAuthenticationCode()
                    }
                )
            } else {
                AuthenticationFormScreenFrame(
                    title: "Check your Messages",
                    description: "Can you enter the verification code?",
                    isValid: $isValidVerificationScreenState,
                    centerContent: {
                        VStack {
                            VerificationCodeInputComponent(
                                config: verificationInputConfig,
                                onSelfAppear: { config in
                                    config.title = "Verification Code"
                                }
                            ).onChange(of: verificationInputConfig.text) {
                                isValidVerificationScreenState = verificationInputConfig.text.count > 3
                            }

                            Text("Resend Code")
                                .background(.red)
                                .padding()
                                .onTapGesture {
                                    Task {
                                        print("Resending Code")
                                        await sendAuthenticationCode()
                                        print("Resending Code Done")
                                    }
                                }
                                .opacity(timeout == 0 ? 1 : 0)
                        }
                    },
                    action: {
                        await verifyAuthenticationCode()
                    }
                )
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    @MainActor
    private func startTimer() {
        timer?.invalidate() // Invalidate existing timer if it exists

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                if timeout > 0 {
                    timeout -= timeout > 0.1 ? 0.1 : timeout
                    verificationInputConfig.errorMessage = formattedTimeout
                    phoneInputConfig.errorMessage = formattedTimeout
                } else {
                    timeout = 0
                    if wasPreviousErrorTimeout {
                        verificationInputConfig.errorMessage = ""
                        phoneInputConfig.errorMessage = ""
                        wasPreviousErrorTimeout = false
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func sendAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        do {
            let response = try await authInteractor.makeLoginCodeRequest(phoneNumber)

            if response.success {
                didSendCode = true
                timeout = 60
            } else {
                timeout = response.timeout
            }

            wasPreviousErrorTimeout = true
        } catch {
            print("\(error) HANDLE THESE!!!")
        }
    }

    func verifyAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        let code = verificationInputConfig.text

        do {
            let response = try await authInteractor.makeLoginRequest(
                phoneNumber,
                code
            )

            // TODO: set the authentication tokens into app storage
//            print("\(response)")
            let success = [
                KeychainHelper
                    .set(for: .AuthenticationToken, value: response.accessToken),
                KeychainHelper
                    .set(for: .RefreshToken, value: response.refreshToken),
            ].first(where: { !$0 })
        } catch {
            if let error = error as? GenericErrors {
                switch error {
                case .invalidCode:
                    verificationInputConfig.errorMessage = "Invalid Verification Code!"
                default:
                    verificationInputConfig.errorMessage = "Unknown Error \(error)"
                }
            }
        }
    }

    private func createIsValidPhoneNumberBinding() -> Binding<Bool> {
        .init(get: {
            timeout == 0 && phoneInputConfig.isValid
        }, set: { _ in })
    }
}

#Preview {
    LoginScreen()
        .preferredColorScheme(.dark)
}
