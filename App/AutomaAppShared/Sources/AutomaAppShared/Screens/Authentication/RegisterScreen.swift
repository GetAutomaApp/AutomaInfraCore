// RegisterScreen.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import AutomaUIKit
import DataTypes
import SwiftUI

public struct RegisterScreen: View {
    @StateObject var phoneInputConfig: PhoneNumberTextInputComponentConfig = .init()
    @StateObject var verificationInputConfig: VerificationCodeInputComponentConfig = .init()
    @State var timeout: Double = 0

    @EnvironmentObject var baseEnvironmentConfig: BaseAppEnvironmentObject

    var authInteractor: AuthenticationControllerInteractor {
        .init(
            baseURL: baseEnvironmentConfig.apiBaseURL
        )
    }

    @State private var wasPreviousErrorTimeout: Bool = false
    @State private var shouldShowTimeoutError: Bool = true
    @State private var timer: Timer? // To avoid race conditions
    @State private var didSendCode: Bool = false
    @State private var isValidVerificationScreenState: Bool = false

    private var formattedTimeout: String {
        let error = String(format: "%.1f", timeout)
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
                                config: verificationInputConfig
                            ) { config in
                                config.title = "Verification Code"
                            }.onChange(of: verificationInputConfig.text) {
                                isValidVerificationScreenState = verificationInputConfig.text.count > 3
                            }

                            Text("Resend Code")
                                .fontTableFont(FontTable.SFPro.Body.body1)
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
                    if shouldShowTimeoutError {
                        verificationInputConfig.errorMessage = formattedTimeout
                        phoneInputConfig.errorMessage = formattedTimeout
                    }
                } else {
                    timeout = 0
                    if wasPreviousErrorTimeout {
                        verificationInputConfig.errorMessage = ""
                        phoneInputConfig.errorMessage = ""
                        wasPreviousErrorTimeout = false
                        shouldShowTimeoutError = true
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    public func sendAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        do {
            let response = try await authInteractor.makeRegisterCodeRequest(
                phoneNumber
            )

            if response.success {
                didSendCode = true
            }

            timeout = response.timeout
            wasPreviousErrorTimeout = true
            shouldShowTimeoutError = true
        } catch let error as GenericErrors {
            phoneInputConfig.errorMessage = error.message
            verificationInputConfig.errorMessage = error.message
            shouldShowTimeoutError = false
        } catch {
            phoneInputConfig.errorMessage = GenericErrors.unknownError.message
            verificationInputConfig.errorMessage = GenericErrors.unknownError.message
            shouldShowTimeoutError = false
        }
    }

    public func verifyAuthenticationCode() async {
        let phoneNumber = phoneInputConfig.phoneNumber
        let code = verificationInputConfig.text

        do {
            let response = try await authInteractor.makeRegisterRequest(
                phoneNumber,
                code
            )

            let success = [
                KeychainHelper
                    .set(
                        for: .authenticationToken,
                        value: response.accessToken
                    ),
                KeychainHelper
                    .set(for: .refreshToken, value: response.refreshToken),
            ].first { !$0 }

            baseEnvironmentConfig.isLoggedIn = true
            baseEnvironmentConfig.isAccepted = false
        } catch let error as GenericErrors {
            phoneInputConfig.errorMessage = error.message
            verificationInputConfig.errorMessage = error.message
            shouldShowTimeoutError = false
        } catch {
            phoneInputConfig.errorMessage = GenericErrors.unknownError.message
            verificationInputConfig.errorMessage = GenericErrors.unknownError.message
            shouldShowTimeoutError = false
        }
    }

    private func createIsValidPhoneNumberBinding() -> Binding<Bool> {
        .init(get: {
            timeout == 0 && phoneInputConfig.isValid
        }, set: { _ in })
    }
}

#Preview {
    RegisterScreen()
}
