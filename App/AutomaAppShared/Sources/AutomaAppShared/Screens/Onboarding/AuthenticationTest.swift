// AuthenticationTest.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

import SwiftUI

public struct AuthenticationTestView: View {
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var resultMessage: String = "Please enter your phone number."
    @State private var isLoading: Bool = false
    @State private var hasError: Bool = false
    @State private var isRegistered: Bool = true

    // Simulating AuthenticationControllerInteractor
    private var interactor: AuthenticationControllerInteractor

    public init(baseURL: String) {
        interactor = AuthenticationControllerInteractor(baseURL: baseURL)
    }

    public var body: some View {
        VStack {
            Toggle(isOn: $isRegistered, label: {
                Text(isRegistered ? "Login" : "Register")
            })
            TextField("Phone Number", text: $phoneNumber)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Code", text: $code)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: {
                    if isRegistered {
                        login()
                    } else {
                        register()
                    }
                }) {
                    Text(isRegistered ? "Login" : "Register")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if hasError {
                    Text("An error occurred. Please try again.")
                        .foregroundColor(.red)
                }

                Text(resultMessage)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            // Reset error and result message when view appears
            resultMessage = "Please enter your phone number."
            hasError = false
        }
    }

    private func register() {
        Task {
            do {
                isLoading = true
                // Request for register code
                if code.isEmpty {
                    try await interactor
                        .makeRegisterCodeRequest(phoneNumber)
                    resultMessage = "Register Code Sent!"
                    hasError = false
                    isLoading = false
                    return
                }

                let accessTokens = try await interactor
                    .makeRegisterRequest(phoneNumber, code)

                resultMessage = "You've been authenticated! \(accessTokens)"
                isRegistered = true
                hasError = false
            } catch {
                resultMessage = "Registration failed: \(error)"
                print(resultMessage, error)
                hasError = true
            }
            isLoading = false
        }
    }

    private func login() {
        Task {
            do {
                isLoading = true
                // Request for login with code
                if code.isEmpty {
                    let codeObj = try await interactor
                        .makeLoginCodeRequest(phoneNumber)

                    if codeObj.timeout > 0 {
                        resultMessage = "Rate Limited! Please wait \(codeObj.timeout)s!"
                    } else if codeObj.success {
                        resultMessage = "Login Code Sent! \(codeObj)"
                    }

                    print("\(codeObj)")

                    hasError = false
                    isLoading = false
                    return
                }

                let accessToken = try await interactor.makeLoginRequest(phoneNumber, code.lowercased())
                resultMessage = "Login successful. Access token: \(accessToken)"
                hasError = false
            } catch {
                resultMessage = "Login failed: \(error)"
                print(resultMessage, error)
                hasError = true
            }
            isLoading = false
        }
    }
}

struct AuthenticationTestView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationTestView(baseURL: "http://localhost:8080")
    }
}
