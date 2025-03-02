// AppLaunch.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  AuthenticationLoop.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 2/22/25.
//
import DataTypes
import SwiftUI

public struct AppLaunch: Sendable {
    let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public func getAccessToken() async -> Bool {
        let authenticationController = AuthenticationControllerInteractor(baseURL: baseURL)
        let keychain = KeychainHelper.self

        print("Access Token")
        var shouldReturn = false
        if let refreshToken = await keychain.get(for: .RefreshToken) {
            let newAccessToken = try? await authenticationController.makeRefreshTokenRequest(
                refreshToken,
                handleInvalidToken: {
                    await keychain.delete(for: .RefreshToken)
                    await keychain.delete(for: .AuthenticationToken)
                    shouldReturn = true
                }
            )

            if shouldReturn {
                return false
            }

            if let newAccessToken {
                await keychain
                    .set(
                        for: .AuthenticationToken,
                        value: newAccessToken.accessToken
                    )
                return true
            } else {
                await keychain.delete(for: .RefreshToken)
                await keychain.delete(for: .AuthenticationToken)
                return false
            }
        }
        return false
    }

    public func isUserAccepted() async -> Bool {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            let response = try await appLaunchInteractor.makeIsUserAcceptedRequest()
            return response
        } catch {
            print("Unknown Response Error, Returning False")
            return false
        }
    }

    public func getClientConfig() async -> AppLaunchClientConfigDTO {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            let response = try await appLaunchInteractor.makeGetClientConfig()
            return response
        } catch {
            print("Unknown Response Error, Returning Default Type")
            return .init()
        }
    }
}
