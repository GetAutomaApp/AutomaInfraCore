// AuthenticationLoop.swift
// Copyright (c) 2025 GetAutomaApp
// All source code and related assets are the property of GetAutomaApp.
// All rights reserved.

//
//  AuthenticationLoop.swift
//  AutomaAppShared
//
//  Created by Simon Ferns on 2/22/25.
//
import SwiftUI

public struct AuthenticationLoop: Sendable {
    public init() {}

    public func getAccessToken() async {
        let authenticationController = AuthenticationControllerInteractor(
            baseURL: "https://api-sandbox.getautoma.app"
        )

        let keychain = KeychainHelper.self

        print("Access Token")
        if let refreshToken = await keychain.get(for: .RefreshToken) {
            let newAccessToken = try? await authenticationController.makeRefreshTokenRequest(
                refreshToken,
                handleInvalidToken: {
                    await keychain.delete(for: .RefreshToken)
                    await keychain.delete(for: .AuthenticationToken)
                }
            )

            if let newAccessToken {
                await keychain
                    .set(
                        for: .AuthenticationToken,
                        value: newAccessToken.accessToken
                    )
            } else {
                await keychain.delete(for: .RefreshToken)
                await keychain.delete(for: .AuthenticationToken)
                return
            }
        }
    }
}
