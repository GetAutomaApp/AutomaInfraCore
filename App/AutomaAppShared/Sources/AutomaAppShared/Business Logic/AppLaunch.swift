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
        public var shouldReturn = false
        if let refreshToken = await keychain.get(for: .refreshToken) {
            let newAccessToken = try? await authenticationController.makeRefreshTokenRequest(
                refreshToken
            ) {
                await keychain.delete(for: .refreshToken)
                await keychain.delete(for: .authenticationToken)
                shouldReturn = true
            }

            if shouldReturn {
                return false
            }

            if let newAccessToken {
                await keychain
                    .set(
                        for: .authenticationToken,
                        value: newAccessToken.accessToken
                    )
                return true
            } else {
                await keychain.delete(for: .refreshToken)
                await keychain.delete(for: .authenticationToken)
                return false
            }
        }
        return false
    }

    public func isUserAccepted() async -> Bool {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            return try await appLaunchInteractor.makeIsUserAcceptedRequest()
        } catch {
            print("Unknown Response Error, Returning False")
            return false
        }
    }

    public func getClientConfig() async -> AppLaunchClientConfigDTO {
        let appLaunchInteractor = AppLaunchControllerInteractor(baseURL: baseURL)
        do {
            return try await appLaunchInteractor.makeGetClientConfig()
        } catch {
            print("Unknown Response Error, Returning Default Type")
            return .init()
        }
    }
}
